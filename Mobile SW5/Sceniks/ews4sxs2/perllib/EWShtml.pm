## Architext Software (c) Copyright 1996

package EWShtml;

use EWShttp;
use EWSspLog;

$ignore_content_type_expr = "";

$largest_fno = 0;

sub new {
  $ignore_content_type_expr = shift;
}

## takes the file to dump to, the ip addr, port , path , and agent name
## and mail, and the prl to put in the dump file.
## Returns ($size, $retmsg, $baseref, $relocateurl, @rets).

## retmsg should begin with "Error $errnum:" or "Http error: $errnum" 
## to denote an error.

## $file is "" if no need to dump.
## $separator: is empty string if 1 doc/dump
##                is non-empty if more than 1 doc/dump

## also set in collector.pl
$DUMP_EXT = "dump.done";
$INFO_EXT = "dump.info";

sub urlToFile { 
    local ($fileRoot, $addr, $port, $path, $agent_name, $agent_mail, 
	   $agent_username, $agent_passwd, $prl, $separator) = @_;
    local ($retmsg, *rets);

    my $dumpFile = "$fileRoot.$DUMP_EXT";
    my $infoFile = "$fileRoot.$INFO_EXT";

    my $location;
    $baseref = "";

    @rets = ();

    my $http = new EWShttp;
    $http->header_agent($agent_name);
    $http->header_from($agent_mail);

    ## for info on this, see section 11.1 of:
    ## www.w3.org/pub/WWW/Protocols/HTTP/1.1/draft-ietf-http-v11-spec-07.txt
    if ($agent_username && $agent_passwd) {
	## pack uuencoded string -- username:passwd
	## this is a base64 encoding.
	$code = pack("u", "$agent_username:$agent_passwd");

	## remove first char (replace with "")
	substr($code, 0, 1) = "";

	## translate while copying var
	##     xlate chars ' ' through '_' to corresponding chars
	##     '+' (the literal) is replicated as necessary
	($bobo = $code) =~ tr# -_#A-Za-z0-9+/#;

	## deletes all non-alphanumeric and non-'+'
	##     d - do not replicate 'searchlist' in 'replacelist'
	##     c - complement the 'searchlist'
	$bobo =~ tr#A-Za-z0-9+/##cd;

	$http->header_authorization("Basic $bobo"); 
    }
    else {
	$http->header_authorization(""); 
    }

    ## $http->printHeaders();
    $retmsg = $http->open($addr, $port, $path);

    if ($retmsg) {
	logMsg($retmsg);
	if ($retmsg =~ /^HTTP error: 30\d/i) {
	    %tmp = $http->response_headers();
	    $location = $tmp{'location'};
	    if ($location) {
		## return location url rather than prl ??
		$http->close();
		return(0, "", $baseref, $location, @rets);
	    }
	    else {
		$http->close();
		return(0, "Error 1007: Bad relocation information($retmsg)", 
		       $baseref, "", @rets);
	    }
	} else {
	    $retmsg =~ s/at.*$//;
	    $retmsg =~ s/[\r\n\s]+/ /g;
	    $http->close();
	    return(0, $retmsg, $baseref, "", @rets);
	}
    }

    my $fno = $http->filenum();
    if ($fno > $largest_fno) {
	&logMsg("DEBUG: fileno=$fno, largest=$largest_fno, prl=[$prl]");
	$largest_fno = $fno;
    }

    %tmp = $http->response_headers();
    ## my $last_modified = $tmp{'last-modified'};

    ## check for bad content types
    my $content_type = $tmp{'content-type'};  
    if (($ignore_content_type_expr) && 
	($content_type =~ m,$ignore_content_type_expr,i)) {
	$http->close();
	return(0, "Page is of ignored content-type '$content_type'.", 
	       $baseref, "", @rets);
    }

    my $mode = (($separator) ? '>>' : '>');
    if (($dumpFile) && (! open(DUMP, "$mode $dumpFile"))) { 
	## errorMsg("Can't open $dumpFile: $!");
	$retmsg = "Error 1005: Can't open '$dumpFile': $!";
	$http->close();
	return(0, $retmsg, $baseref, "", @rets);
    }

    ####
    ## select((select(DUMP), $| = 1)[0]);
    
    $oldend = "";
    $begin = "";
    $bcnt = 0;
  READLOOP: 
    while (1) {
	my ($len, $retmsg) = $http->get(8192);
	$body = $http->{'body'};
	if ($len > 0) {
	    if ($bcnt < 1024) {
		$begin .= $body;
		$bcnt += $len;
		if ($bcnt >= 1024) {
		    if (goodPage($begin)) {
			if ($dumpFile) {
			    print DUMP "$separator" if ($separator);
			    if ($separator) {
				if (! print DUMP "$prl\n") {
				    $retmsg="Error 1006: Can't write to $dumpFile: $!";
				    $http->close();
				    return(0, $retmsg, $baseref, "", @rets);
				}
			    }
			    if (! print DUMP $begin) {
				$retmsg="Error 1006: Can't write to $dumpFile: $!";
				$http->close();
				return(0, $retmsg, $baseref, "", @rets);
			    }
			}
			$begin =~ s/<[^<>]+>/&tag($&)/ge;
			$extra_parse = $bcnt - 512;
			$extra_parse = 0 if ($extra_parse < 0);
			$oldend = substr($begin, $extra_parse);
		    }
		    else {
			if ($dumpFile) {
			    close(DUMP);
			    unlink $dumpFile unless ($separator);
			}
			$http->close();
			return(0, 
			       "Page is not textual. " . 
			       "Content-type: '$content_type'", 
			       $baseref, "", @rets);
		    } 
		}
	    }
	    else {
		$to_scan = $oldend.$body;
		$to_scan =~ s/<[^<>]+>/&tag($&)/ge;
		if (($dumpFile) && (! print DUMP $body )) { 
		    $retmsg = "Error 1006: Couldn't write to '$dumpFile':$!";
		    $http->close();
		    return(0, $retmsg, $baseref, "", @rets);
		}
		$extra_parse = $len - 512;
		$extra_parse = 0 if ($extra_parse < 0);
		$oldend = substr($body, $extra_parse);
	    }
	}
	if ($len < 0) {
	    if ($dumpFile) {
		print DUMP "\n";
		close(DUMP);
		unlink $dumpFile unless ($separator);
	    }
	    $http->close();
	    return(0, $retmsg, $baseref, "", @rets);
	}
	if ($len == 0) {
	    last READLOOP;
	}
    }
    if ($bcnt > 0 && $bcnt < 1024) {
	if (&goodPage($begin)) {
	    if ($dumpFile) {
		print DUMP "$separator" if ($separator);
		if ($separator) {
		    if (! print DUMP "$prl\n" ) { 
			$retmsg = "Error 1006: Couldn't write to '$dumpFile': $!";
			## errorMsg("Couldn't write to $dumpFile: $!");
			$http->close();
			return(0, $retmsg, $baseref, "", @rets);
		    }
		}
		if (! print DUMP $begin ) { 
		    $retmsg = "Error 1006: Couldn't write to '$dumpFile': $!";
		    ## errorMsg("Couldn't write to $dumpFile: $!");
		    $http->close();
		    return(0, $retmsg, $baseref, "", @rets);
		}
	    }
	    $begin =~ s/<[^<>]+>/&tag($&)/ge;
	}
	else {
	    if ($dumpFile) {
		close(DUMP);
		unlink $dumpFile unless ($separator);
	    }
	    $http->close();
	    return(0, "Page is not textual. Content-type is '$content_type'.", 
		   $baseref, "", @rets);
	}
    }

    close(DUMP) if ($dumpFile);
    $http->close();
    if ($dumpFile && ! open(INFO, "$mode $infoFile")) {
	## errorMsg("Can't open $infoFile: $!");
	$retmsg = "Error 1005: Can't open '$infoFile': $!";
	unlink $dumpFile unless ($separator);
	return(0, $retmsg, "", "", @rets);
    } else {
	if (! print INFO "$prl\n") {
	    $retmsg="Error 1006: Can't write to $infoFile: $!";
	    unlink $dumpFile unless ($separator);
	    return(0, $retmsg, "", "", @rets);
	}
	close(INFO);
    }
    return($bcnt, "", $baseref, "", @rets);
}

sub tag {
    my ($tag) = shift;
    my ($ref, $origtag);

    $origtag = $tag;

    if ($tag =~ /^<A/i) {
	$tag =~ s/<A\w+//;
	$tag =~ s/>//;
	
	($ref) = ($tag =~ /HREF\s*=\s*(\S+)/i);
	$ref =~ s/^\"//;
	$ref =~ s/\"$//;
        $ref =~ s/\".*//;

	if ($ref && $ref !~ /^#/) {
	    push(@rets, $ref);
	}
    }
    
    $origtag;
}

sub robot_parse_new {
    local($body, $agent, $host) = @_;

    ## tab-separated list of excluded paths
    local $archi = "";    ## when we're explicitly listed.
    local $default = "";  ## the default rule.
    local($field, $value, $valueItem, $newpath);
    local %rule;

    ## $state can be 'non-archi', 'archi', or 'default'
    local $state = 'non-archi';
    local $explicit = 0;   ## whether or not there's an explicit rule for us.

    for (split(/[\n\r]+/, $body)) {

        ## clean up lines of file
        s/\#.*$//;                      # nuke comments from eol
        s/\s+$//;                       # nuke trailing whitespace
        if (/^\s*$/) {          # blank line
            next;
        }

        ## ignore bobo lines
        if (!/:/) {
            warningMsg("$host/robots.txt: Invalid line '$_'");
            next;
        }

        ## get field (lowercased) and value
        ## split using ':' (ignoring whitespace on either side)
        ($field, $value) = split(/\s*:\s*/, $_, 2);
        $field =~ y/A-Z/a-z/;
        $value =~ y/A-Z/a-z/;

        ## see whether in "add to exclude" mode...
        if ($field eq 'user-agent') {
            if ($value =~ /$agent/oi) {
                $state = 'archi';
                $explicit = 1;
            }
            if ($value =~ /^\s*\*\s*$/) {             
                $state = 'default';
            }
        }
        ## add 'disallow' info to either 'archi' or 'default' rules
        elsif (($field eq 'disallow') && ($state ne 'non-archi')) {
            foreach $valueItem (split(" ", $value)) {
                if ($valueItem =~ /\S/) {    ## if non-whitespace
                    $newpath = fixpath($valueItem);
                    $rule{$state} .= "$newpath\t";
                }
            }
        }
        next;
    }

    $result = $explicit ? $rule{'archi'} : $rule{'default'};
    if ($result) {
        chop($result);  ## remove final \t
        return $result;
    } else {
        return '*';
    }           
}

sub robot_parse_old {
    local($body, $agent, $host) = @_;
    
    local($result) = "";  ## tab-separated list of excluded paths
    local($field, $value, $valueItem, $newpath);

    local $state = 'non-archi';
    for (split(/[\n\r]+/, $body)) {
	
	## clean up lines of file
	s/\#.*$//;			# nuke comments from eol
	s/\s+$//;			# nuke trailing whitespace
	next if /^\s*$/;		# nuke blank lines
	
	## ignore bobo lines
	if (!/:/) { 
	    warningMsg("$host/robots.txt: Invalid line '$_'\n"); 
	    next;
	}
	
	## get field (lowercased) and value
	## split using ':' (ignoring whitespace on either side)
	($field, $value) = split(/\s*:\s*/, $_, 2);
	$field =~ y/A-Z/a-z/;

	## if in 'archi' state, add 'disallow' info...
	if (($field eq 'disallow') && ($state eq 'archi')) {
	    foreach $valueItem (split(" ", $value)) {
		if ($valueItem =~ /\S/) {    ## if non-whitespace
		    $newpath = fixpath($valueItem);
		    $result .= "$newpath\t";
		    ## $result = join("\377", split(/\377/, $rslt), $newpath);
		}
	    }
	} 

	## see whether in "add to exclude" mode...
	elsif ($field eq 'user-agent') {
	    $state = 
		(($value =~ /$agent/oi || $value =~ /^\s*\*\s*$/) 
		 ? 'archi' 
		 : 'non-archi');
	}
	
	next;
    }

    if ($result) {
	chop($result);  ## remove final \t
    } else {
	$result = '*';
    }
    return $result;
}

sub robot_parse_old {
  local($body, $agent) = @_;
  local($rslt, $state, $field, $value, $vl, $newpath);

  $state = 'bad-user-agent';
  for (split(/[\n\r]+/, $body)) {
    ## Clean up
    s/\#.*$//;
    s/\s+$//;
    next if /^\s*$/;

    ($field, $value) = split(/\s*:\s*/, $_, 2);
    $field =~ y/A-Z/a-z/;
    if ($state eq 'bad-user-agent') {
      if ($field eq 'user-agent' && 
       ($value =~ /$agent/oi || $value =~ /^\s*\*\s*$/)) {
       $state = 'good-user-agent';
      }
    } elsif ($state eq 'good-user-agent') {
      if ($field eq 'disallow') {
        $state = 'read-disallow';
      }
    }

    if ($state eq 'read-disallow') {
      if ($field eq 'disallow') {
	## Exclude the URL.
        $_ = $value;
        foreach $vl (split) {
	  if ($vl =~ /\S/) {
            $newpath = &fixpath($vl);
            $rslt = join("\377", split(/\377/, $rslt), $newpath);
	  }
        }
      } elsif ($field eq 'user-agent') {
        return $rslt ? $rslt : '*';
      }
    }
  }

  return $rslt ? $rslt : '*';
}

## Need to do better on the foll.
sub robot_parse_file {
  local($robotfile, $agent) = @_;
  local($rslt, $state, $field, $value, $vl, $newpath);

  $state = 'bad-user-agent';

 if (open(ROBOT, "$robotfile")) {
   while (<ROBOT>) {
    ## Clean up
    s/\#.*$//;
    s/\s+$//;
    next if /^\s*$/;

    ($field, $value) = split(/\s*:\s*/, $_, 2);
    $field =~ y/A-Z/a-z/;
    if ($state eq 'bad-user-agent') {
      if ($field eq 'user-agent' && 
       ($value =~ /$agent/oi || $value =~ /^\s*\*\s*$/)) {
       $state = 'good-user-agent';
      }
    } elsif ($state eq 'good-user-agent') {
      if ($field eq 'disallow') {
        $state = 'read-disallow';
      }
    }

    if ($state eq 'read-disallow') {
      if ($field eq 'disallow') {
	## Exclude the URL.
        $_ = $value;
        foreach $vl (split) {
	  if ($vl =~ /\S/) {
            $newpath = &fixpath($vl);
            $rslt = join("\377", split(/\377/, $rslt), $newpath);
	  }
        }
      } elsif ($field eq 'user-agent') {
        return $rslt ? $rslt : '*';
      }
    }
  }
 }
 close (ROBOT);

  return $rslt ? $rslt : '*';
}


sub robot_exclude {
  local($path, $exclusions) = @_;
  if ($exclusions ne '*') {
    for $excl (split(/\377/, $exclusions)) {
      return 1 if (substr($path, 0, length($excl)) eq $excl);
    }
  }
  return 0;
}


sub goodPage {
    my($test) = substr(shift , 0 , 1024);
    my($olen, $nlen, $per);

    ## set globals for $base_host, $base_port, $base_path  ...if found
    if ($test =~ /<base\s+href\s?=\s?\"http:\/\/([^\"]+)/i) {
	$baseref = "http://" . $1;
	## print "$addr, $port, $path\n";
	## print "baseref: $baseref\n";
    }

    return 0 if ($test =~ /^begin \d\d\d /i);
    $olen = length($test);
    $test =~ s/[\w\s\!\"\#\$\%\&\'\(\)\*\+\,\-\.\/\:\;\<\=\>\?\@\[\\\]\^\_\`\{\|\}\~]+//g;
    $nlen = length($test);
    $per = $nlen / $olen;
    return 1 if ($per < 0.2);
    return 0;
}


sub replace {
    my ($orig) = shift;

    my $str = chr(hex($orig));

    @funkyStrings = ('\!', '\"', '\#', '\$', '\%', '\&', '\\', '\(', '\)', 
		     '\*', '\+', '\,', '\-', '\.', '\:', '\;', '\<', '\=', 
		     '\>', '\?', '\@', '\[', '\\', '\]', '\^', '\_', '\`', 
		     '\{', '\|', '\}', '\~');

    foreach $funkyStr (@funkyStrings) {
	return $str if ($str eq $funkyStr);
    }
    return "%$orig";
}


sub fixpath {
    my ($path) = @_;

    ## replace '/./' with '/'
    1 while $path =~ s|/\./|/|g;

    ## replace multiple slashes with a single one
    1 while $path =~ s|/{2,}|/|;

    ## replace './' at beginning of line with ''
    1 while $path =~ s|^\./||;

    ## replace '/xx/../' with '/' whenever possible

    ## replace '/../' at beginning with '/'
    1 while $path =~ s#^/\.\./#/#;

    $finalCh = "";
    $finalCh = "/" if ($path =~ m/\/$/);

    @pathParts = split('/', $path);
    @realParts = ();
    for ($i=0; $i<=$#pathParts; $i++) {

	if ($pathParts[$i] eq ".." &&
	    $#realParts >= 0 &&
	    $realParts[$#realParts] ne "..")
	{
	    pop(@realParts);
	} else {
	    push(@realParts, $pathParts[$i]);
	}
    }
    $path = join("/", @realParts);
    $path .= $finalCh;

    ## remove any targets at end of url
    $path =~ s/\#.*$//;

    ## hex shit -- eg. %3F --, then replace hex shit with char
    $path =~ s/%([\dA-Fa-f][\dA-Fa-f])/replace($1)/eg;
    return $path;
}

sub fixpath_old {
    my ($path) = @_;
    ## canonicalize the URL remove "zzz/./zzz" sequences, and handle
    ## sequences like "zzz/../zzz".
    1 while $path =~ s|/\./|/|g;
    1 while $path =~ s|^\./||;
    1 while $path =~ s#/([^/]|[^/][^/.]|[^/.][^/]|[^/]{3,})/\.\./#/#g;
    1 while $path =~ s#^([^/]|[^/][^/.]|[^/.][^/]|[^/]{3,})/\.\./##g;
    1 while $path =~ s#^/\.\./#/#;
    $path =~ s/\#.*$//;
    $path =~ s/%([\dA-Fa-f][\dA-Fa-f])/replace($1)/eg;
    return $path;
}

sub parse_url {
    my ($url) = shift;
    my ($proto, $host, $port, $def_path) = @_;
    my $path;

    ## First parse the protocol part.
    if ($url =~ m|^(\w+):|) {
	$proto = $1;
	$url = $';
    }

    if ($url =~ m|^//([^/]+):(\d+)$|) {
	($host, $port) = ($1, $2);
	$url = "/";
    } elsif ($url =~ m|^//([^/]+)$|) {
	($host, $port) = ($1, 80);
	$url = "/";
    } elsif ($url =~ m|^//([^/]+):(\d+)/|) {
	($host, $port) = ($1, $2);
	$url = "/" . $';
    } elsif ($url =~ m|^//([^/]+)/|) {
	$host = $1;
	$url = "/" . $';
    }
    
    $path = $url;
    if ($path !~ m|^/| && $def_path) {
	$def_path =~ s|/[^/]*$||;
	$path = "$def_path/$path";
    }

    $host = "\L$host";
    ($proto, $host, $port, $path);
}

1;

