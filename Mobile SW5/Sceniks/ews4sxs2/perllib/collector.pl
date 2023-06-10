#!/usr/local/bin/perl5

##
## SPIDER_HOME environment variable should be set to the working directory.
## config files required:
##   config
##   initialUrls.cfg
##   domainList.cfg
##  
## others if needed:
##   fetchUrlFilter.cfg
##   dumpUrlFilter.cfg
##   retryLogic.cfg
##

##
## writes files:
##   log: log file
##   state: current state saved at regular intervals
##   overflow: IF urls are not fetched because we have exceeded 
##              the maxDumps/site criterion, then they are written out to
##              this file.
## 

##
## options: [-restart [-overflow]]
## -restart to start from the last saved state, .ie. do not start fresh.
##   -overflow if you want to reconsider overflow urls on restart. You might 
##     want to use this option if you increased maxDumps/site.
##
##

### this simply puts the present working directory onto @INC.
BEGIN {
    $bindir = $0;   ## name of present script
    $bindir =~ s|/[^/]*$||;   ## removes stuff after final '/'
    chop($bindir = `pwd`) if (($bindir eq $0) || ($bindir eq "."));
    unshift(@INC, $bindir);  ## prepends bindir onto INC
}

use GDBM_File;
use Opt;
use EWSspConfig;
use EWSspLog;
use EWShttp;
use EWShtml;
use EWSspDomainFilter;
use EWSspUrlFilterFancy;
use EWSspRetryLogic;
use AddrDb;

$| = 1;  ## flush stuff as you write it.

sub get_robot;
sub skip;
sub save_state;
sub markVisited;
sub ifVisited;
sub numerically;
sub handleError;
sub getRetryUrls;

## use Opt instead of doing this...
## determine whether to restart and whether to use overflow
$restart = Opt::flag("-restart");
$retry_overflow = 1 if Opt::flag("-overflow");
##exit(0);

## create a logfile -- *append* to it if you're restarting
EWSspLog::new($EWSspConfig::logFile, $restart);

warningMsg("Ignoring '-overflow' option. Can be used only with '-restart'") 
    if ($retry_overflow && !$restart);
$retry_overflow = 0 unless ($restart);

$domainFilt = new EWSspDomainFilter($EWSspConfig::domainListFile);
$domainFilt || fatalMsg("Cannot obtain Domain List");

if (-e $EWSspConfig::fetchUrlFilterFile) {
    $urlFilt = new EWSspUrlFilterFancy($EWSspConfig::fetchUrlFilterFile);
    ## $urlFilt->debugPrint();
    $urlFilt || fatalMsg("Cannot obtain Url Filter List");
}
if (-e $EWSspConfig::dumpUrlFilterFile) {
    $dumpUrlFilt = new EWSspUrlFilterFancy($EWSspConfig::dumpUrlFilterFile);
    $dumpUrlFilt || fatalMsg("Cannot obtain Dump Url Filter List");
}

$retryObj = new EWSspRetryLogic($EWSspConfig::retryLogicFile);
$retryObj || fatalMsg("Cannot obtain Retry Logic Info");

$savefile = $EWSspConfig::saveFile;
$polite = $EWSspConfig::polite_time;
$agent_name = $EWSspConfig::user_agent;
$agent_mail = $EWSspConfig::from_agent;
$maxDumps = $EWSspConfig::maxDumpsPerSite;
$ignore_robot_error = $EWSspConfig::ignore_robot_error;
$addr_db_infile = $EWSspConfig::addr_db_infile;
$addr_db_outfile = $EWSspConfig::addr_db_outfile;
%bad_robot_site = ();
$last_save_time = time;
$save_interval = 1 * 60; 
$dfcnt = 0;
$fcnt = 0;
%nDumps = ();

# overflow urls not yet saved.
@overflow_urls = ();

## earliest u need to retry a url
$earliest = undef;

@todo = ();
@redo = ();
$total_space = 0;

$separator = "";
$separator = $EWSspConfig::docSeparator if ($EWSspConfig::docsPerDump > 1);

@save_variables = 
    (
     '%robots',
     '%bad_robot_site',
     '%inlist',
     '@todo',
     '@redo',
     '%retry_left',
     '%retry_at',
     '%nDumps',
     '@EWShttp::addr_cache',
     '%EWShttp::addr_cache',
     '$fcnt',
     '$total_space'
     );

logMsg("DEBUG: restart = $restart");
logMsg("DEBUG: retry_overflow = $retry_overflow");

if ($restart) {
    if (! restore_state()) {
	fatalMsg("Unable to restart");
    }
    $earliest = time;
}

AddrDb::refreshDb();
AddrDb::loadDb();
readInInitialUrls();

## overflow urls
$open_mode = ">";
if ($restart) {
  $open_mode = (($retry_overflow) ? '+<' : '>>');
} 
logMsg("DEBUG: open_mode = $open_mode");
logMsg("DEBUG: retry_overflow = $retry_overflow");
$dfcnt = int($fcnt / $EWSspConfig::docsPerDump);

open (OVERFLOW, "$open_mode $EWSspConfig::overflowFile")
    || die "Couldn't open $EWSspConfig::overflowFile: $!";
select((select(OVERFLOW), $| = 1)[0]);

if ($retry_overflow) {
    while (<OVERFLOW>) {
	## print "ov: $_";
	next if (/^\#/);
	chop;
	push(@todo, $_);
    }
    seek(OVERFLOW, 0, 0) || die "seek failed: $!";
    truncate(OVERFLOW, 0) || die "truncate failed: $!";
}

OUTER: while (@todo || (@redo) || (keys %retry_at)) {
    $didsomething = 0;
    
    logTimestamp "NEWLOOP\n";
  MAIN:
    while (@todo) {
	
	my $curtime = time;
	if ($curtime >= ($last_save_time + $save_interval)) {
	    save_state($savefile, $curtime);
	    $last_save_time = $curtime;
	    @overflow_urls = ();
	}
	
	$prl = shift(@todo);
	($proto, $addr, $port, $path, $host) = split(/\t/, $prl);
	
	## check on dumps
	$maxDocsForHost = $urlFilt->maxDocsForHost("$host");

	if ($maxDocsForHost >= 0) {
	    if ($nDumps{$addr} >= $maxDocsForHost) {
		skip("$proto://$host:$port$path: exceeds max dumps specifically for this site.");
		push(@overflow_urls, $prl);
		next MAIN;
	    }
	}
	elsif ($maxDumps && ($nDumps{$addr} >= $maxDumps)) {
	    skip("$proto://$host:$port$path: exceeds general max dumps for site.");
	    push(@overflow_urls, $prl);
	    next MAIN;
	}
	
	## check on polite time
	$ptime = $polite{$addr};
	if ($ptime && ($ptime > ($curtime - $polite))) {
	    push(@redo, $prl);
	    next MAIN;
	}
	
	## check on robots.txt exclusion
	
	if ($bad_robot_site{$addr}) {
	    errorMsg("Giving up on $prl: Failed to get robots.txt for $host.");
	    next MAIN;
	}
	$exclusions = $robots{$addr};

	## HACK
	if ($host eq "detnews.com") {
	    $exclusions = '*';
	}

	if (!$exclusions) {
	    if (get_robot($addr, $host, $port, $ignore_robot_error)) {
		push(@redo, $prl);      
	    }
	    else {
		$bad_robot_site{$addr} = 1;
		errorMsg("Giving up on $prl: " . 
			 "Failed to get robots.txt for $host.");
	    }
	    $polite{$addr} = time;
	    $didsomething = 1;
	    next MAIN;
	}
	if (EWShtml::robot_exclude($path, $exclusions)) {
	    skip("http://$host:$port$path: excluded by robots.txt file");
	    next MAIN;
	}
	
	my($nurl) = "$proto://$host:$port$path";
	if (($dumpUrlFilt) 
	    && ($dumpUrlFilt->excluded("$proto://$host:$port", $path))) {
	    $dump = 0;
	    $dumpRoot = "";
	}

        else {
            $dumpedPage = 1;
            $extension = "";
            if ($path !~ /\/$/) {
                @parts = split(/\./, $path);
                $extension = $parts[$#parts] if ($#parts);
            }
            ## print "ext: $extension\n\n";

            $dumpRoot =
                "${EWSspConfig::dumpDir}/$dfcnt";


            ## get rid of old version of file.
            if (($EWSspConfig::docsPerDump > 1) &&
                (($fcnt % $EWSspConfig::docsPerDump) == 0) &&
                (-e "$dumpRoot.$DUMP_EXT"))
            {
                unlink "$dumpRoot.$DUMP_EXT";
                unlink "$dumpRoot.$INFO_EXT";
            }
        }

	
	## get the page and dump it to disk
	@rets = ();
	## prl in proper order for dumps
	$dprl = join("\t", $proto, $host, $port, $path);
	$agent_username = $urlFilt->usernameForHost($host);
	$agent_passwd = $urlFilt->passwdForHost($host);
	($size, $retmsg, $baseref, $relocate, @rets) = 
	  EWShtml::urlToFile($dumpRoot, $addr, $port, $path, 
			     $agent_name, $agent_mail, 
			     $agent_username, $agent_passwd,
			     $dprl, $separator);
	
	$polite{$addr} = time;
	
	######### clean up the foll. err check.
	$errnum = 0;
	if ($retmsg) {
	    if ($retmsg =~ /^HTTP error: (\d+)/i) {
		$errnum = $1;
	    }
	    elsif ($retmsg =~ /^Error (\d+):/i) {
		$errnum = $1;
	    }
	}
	
	if ($relocate) {
	    if ($baseref) {
		($base_proto, $nada, $base_hostNport, $base_path) 
		    = split('/', $baseref, 4);
		($base_host, $base_port) = split(':', $base_hostNport);
		$host = $base_host;
		$port = $base_port if $base_port;
		$path = "/$base_path";
	    }
	    $nprl = url2prl($relocate, "http", $host, $port, $path);
	    if ($nprl && (!ifVisited($nprl))) {
		push(@redo, $nprl);
		markVisited($nprl);
	    }
	    $didsomething = 1;
	}
	elsif ($errnum) {
	    if ($left = handleError($prl, $host, $errnum)) {
		logMsg("Retry $left more time(s). " . 
		       "http://$host:$port$path: $retmsg");
	    } else {
		errorMsg("Giving up on http://$host:$port$path: $retmsg");
	    }
	}
	elsif ($retmsg) {
	    skip("http://$host:$port$path: $retmsg");
	}
	else {
	    if ($dumpRoot) {
		logMsg("GOT[$fcnt][$dfcnt]: $prl");
		$fcnt += 1;
		$dfcnt = int($fcnt / $EWSspConfig::docsPerDump);
		## $dfcnt++ if (($fcnt % $EWSspConfig::docsPerDump) == 0);
		$total_space += $size;
		$nDumps{$addr} += 1;
	    }
	    else {
		skip("Dump of $nurl: dump exclusion");
	    }
	    $didsomething = 1;

	    ## add parsed urls to todo list...
	    if ($baseref) {
		($base_proto, $nada, $base_hostNport, $base_path) 
		    = split('/', $baseref, 4);
		($base_host, $base_port) = split(':', $base_hostNport);
		$host = $base_host;
		$port = $base_port if $base_port;
		$path = "/$base_path";
	    }
	    for $url (@rets) {    
		$nprl = url2prl($url, "http", $host, $port, $path);
		if (($nprl) && (!ifVisited($nprl))) {
		    push(@todo, $nprl);
		    markVisited($nprl);
		}
	    }
	}
    }

    ($sleeptime, @retryUrls) = getRetryUrls();
    if (!($didsomething || (@retryUrls))) {
	if ($sleeptime) {
	    if (($polite < $sleeptime) && (@redo)) {
		sleepFor($polite);
	    }
	    else {
		sleepFor($sleeptime); 
		($sleeptime, @retryUrls) = getRetryUrls();
	    }
	}
	else {
	    sleepFor($polite) if (@redo);
	}
    }
    @todo = (@retryUrls, @redo);
    @redo = ();
}


save_state($savefile, time); 
logMsg("\#\# DONE at " . time_stamp(time) . 
  ". Dumped $total_space bytes into $fcnt files\n");
close(OVERFLOW);

system("touch $EWSspConfig::doneFile");
AddrDb::saveDb();
system("rm $addr_db_infile");
system("mv $addr_db_outfile $addr_db_infile");

########################################################################
########################################################################

###----------------------
### URL FETCHER ROUTINES
###----------------------

sub readInInitialUrls {
    open(LST, $EWSspConfig::initialUrlListFile) 
	|| die "Couldn't open $EWSspConfig::initialUrlListFile";
    while ($url = <LST>) {
	$url =~ s/\n$//;
	## next unless ($url =~ /^http:\/\//);
	
	$nprl = url2prl($url, "http", "", 80, "");
	if (($nprl) && (!ifVisited($nprl))) {
	    push(@todo, $nprl);
	    markVisited($nprl);
	}
    }
    close(LST);
}

sub get_robot {
    local($addr, $host, $port, $ignore_robot_error) = @_;
    my($result, $show_result);

    logMsg("Getting robots.txt for $host ($addr)");

    EWShtml::new(EWSspConfig::ignoredContentTypeExpr());
    my $http = new EWShttp;
    $http->header_agent($agent_name);
    $http->header_from($agent_mail);
    $http->header_authorization("");
    $result = $http->open($addr, $port, '/robots.txt');

    if ($result) {
	$show_result = $result;
	$show_result =~ s/at.*$//;
	$show_result =~ s/[\r\n\s]+/ /g;
    
	## Ignore robots.txt on all errors.
	if ($ignore_robot_error || ($result =~ /^HTTP error: 4\d\d/i)
	    || ($result =~ /^HTTP error: 3\d\d/i)) {
	    logMsg("Ignoring robots.txt err for $host ($addr): $show_result");
	    $robots{$addr} = '*';   ## all is well
	    $http->close();
	    return 1;
	}
	else {
	    errorMsg("http://$host:$port/robots.txt: $show_result");
	    $http->close();
	    return 0;
	}
    }

    ## if you get here, you assume there was no error in getting it.
    my ($grs, $retmsg) = $http->get(32768);
    if ($grs <= 0) {
	errorMsg("Giving up on http://$host:$port/robots.txt: $retmsg");
	$http->close();
	return 0;
    }
    my $body = $http->body();

    ($grs, $retmsg) = $http->get(32768);
    if ($grs == 0) {
	if (1) {
	    open(ROBOT, ">$EWSspConfig::spider_home_dir/$host.robots");
	    print ROBOT $body;
	    $newBody = $http->body();
	    print ROBOT $newBody;
	    close(ROBOT);
	}
	$robots{$addr} = EWShtml::robot_parse_new($body, $agent_name, $host);
	logMsg("robots.txt info for $addr ($host:$port): $robots{$addr}\n");
	$http->close();
	return 1;
    }

    my $robotfile = "$dumpDir/robots.$$";
    if (! open(ROBOT, "$dumpDir/robots.$$")) {
	errorMsg("Error opening $robotfile: $!");
	$http->close();
	return 0;
    }
    print ROBOT $body;
    print ROBOT $http->body();
    while ((($grs, $retmsg) = $http->get(32768)) && ($grs > 0)) {
	print ROBOT $http->body();
    }
    close (ROBOT);
    $http->close();
    $robots{$addr} = EWShtml::robot_parse_file($robotfile, $agent_name);
    1;
}


sub skip {
  $msg = shift;
  warningMsg("Skipping $msg");
}

sub save_state {
  my ($savefile, $timeval) = @_;

  my($tstamp) = time_stamp($timeval);

  if (-e $savefile) {
    system("mv $savefile $savefile.bak");
    if ($?) {
      errorMsg("System Error $?: Could not 'mv $savefile $savefile.bak'");
      return 0;
    }
  }
  if (! open (SAVE, "> $savefile"))  {
    errorMsg("Save State Failed. Cannot open '$savefile': $!");
    system("mv $savefile.bak $savefile");
    errorMsg("System Error $?: Could not 'mv $savefile.bak $savefile'") if ($?);
    return 0;
  }

  print SAVE "## State at $tstamp\n";

  my($var, $vtype, $vname, $f);
  foreach $var (@save_variables) {
    ($vtype, $vname) = ($var =~ /^([\%\@\$])(\w+(::\w+)?)$/);
    if ($vtype eq '%') {
      print SAVE "\%\% BEGIN \%$vname\n";
      ###### HACK ?????????
      if ($vname eq 'EWShttp::addr_cache') {
        foreach $f (keys %EWShttp::addr_cache) {
          print SAVE "$f:", join(".", unpack("C4", $EWShttp::addr_cache{$f})), "\n";
        }
      }
      else {
        foreach $f (keys %$vname) {
          print SAVE "$f:$$vname{$f}\n";
        }
      }
      print SAVE "\%\% END $vname\n";
    }
    elsif ($vtype eq '@') {
      print SAVE "\%\% BEGIN \@$vname\n";
      foreach $f (@$vname) {
        print SAVE "$f\n";
      }
      print SAVE "\%\% END $vname\n";
    }
    elsif ($vtype eq '$') {
      print SAVE "\%\% BEGIN \$$vname\n";
      print SAVE "$$vname\n";
      print SAVE "\%\% END $vname\n";
    }
    else {
      die "Invalid entry in @save_variables";
    }
  }

  close(SAVE);


  ## save overflow urls
  if (@overflow_urls) {
    print OVERFLOW "## $tstamp\n";
    foreach $f (@overflow_urls) {
      print OVERFLOW "$f\n";
    }
  }
  logMsg("## SAVE_STATE: $tstamp");
1;
}

sub restore_state {
  if (! open (SAVE, "< $savefile"))  {
    errorMsg("Restore State Failed. Cannot open '$savefile': $!");
    return 0;
  }
  while (<SAVE>) {
    next if /^#/;
    chop;
    if (/%% BEGIN ([\%\@\$])(\w+(::\w+)?)/) {
      $vtype = $1;
      $vname = $2;
    }
    elsif (/%% END/) {
      $vtype = "";
      $vname = "";
    }
    else {
      if ($vtype eq '%') {
        ($f1, $f2) = split(":");
        if ($vname eq 'EWShttp::addr_cache') {
	  $EWShttp::addr_cache{$f1} = pack('c4', split(/\./, $f2));
        }
        else { 
	  $$vname{$f1} = $f2;
        }
      }
      elsif ($vtype eq '@') {
	push(@$vname, $_);
      }
      elsif ($vtype eq '$') {
	$$vname = $_;
      }
      else {
	errorMsg("Corrupt state file: $savefile");
	return 0;
      }
    }
  }
1;
}

sub markVisited {
  my $prl = shift;
  my($proto, $addr, $port, $path, $host) = split(/\t/, $prl);
  my $nprl = join("\t", $proto, $addr, $port, $path);

  $inlist{$nprl} = 1;
}

sub ifVisited {
  my $prl = shift;
  my($proto, $addr, $port, $path, $host) = split(/\t/, $prl);
  my $nprl = join("\t", $proto, $addr, $port, $path);

  return $inlist{$nprl};
}

## ###
## Parse url.
## Check domain restriction.
## Fix Paths
## Check url restriction.
## Form prl
##
## Log any Errors in the process.
## Global: domainFilt and urlFilt.
## ###

sub url2prl {
    my($url) = shift;

    ## get defaults and rel path args
    my($proto, $host, $port, $path) = @_;
    
    ## print "URL:  $url\n";
    ## print "PRE:  $host, $port, $path\n";
    ($proto, $host, $port, $path) = 
      EWShtml::parse_url($url, $proto, $host, $port, $path);

    ## DEC13
    ## at this point have the URL.  whether or not you wanna give
    ## it to frumkin is the question.
    ## print "";

    ## print "POST: $host, $port, $path\n\n";

    if ($proto !~ /http/i) {
	skip("$url: not http protocol");
	return "";
    }

    ## Need to do better on the foll.
    if ($host) {
	return 0 if (($host eq "www") || ($host eq "www."));
    }
    
    if (! $domainFilt->included("$host:$port")) {
        skip("$proto://$host:$port$path: domain restriction");
        return "";
    }
    
    my $newpath = EWShtml::fixpath($path);
    my $nurl = "$proto://$host:$port$newpath";
    
    if (EWSspConfig::ignoredUrlSuffix($newpath)) {
	skip("$nurl: ignored path suffix");
	return "";
    }
    
    if (EWSspConfig::ignoredPath($newpath)) {
	skip("$nurl: ignored path pattern");
	return "";
    }
    
    if (($urlFilt) && ($urlFilt->excluded("$proto://$host:$port", $newpath))) {
	skip("$nurl: url exclusion");
	return "";
    } else {
	## logMsg("  not excluded: $host:$port$newpath");
    }

    ## GET PACKED ADDRESS
    my $paddr = EWShttp::addrByName($host);
    my $addr;

    ## if succeeded in getting address, update the backup repository.
    if ($paddr) {
	$addr = join(".", unpack("C4", $paddr));
        AddrDb::setAddrFor($host, $addr);
    } 

    ## if failed to get address, check backup repository.
    else {
	$addr = AddrDb::getAddrFor($host);
	if (!$addr) {
	    errorMsg("Skipping http://$host:$port$path: " . 
		     "Couldn't get addr for $host");
	    return "";
	}
    }

    return join("\t", $proto, $addr, $port, $newpath, $host);
}

sub numerically { $a <=> $b;}

sub getRetryUrls {
  my $curtime = time;

  #&logMsg("\nDEBUG: getRetryUrls: curtime = $curtime");
  #&logMsg("DEBUG: getRetryUrls: earliest = $earliest") if ($earliest);
  return (0) if (!$earliest);
  return ($earliest - $curtime + 1) if ($earliest > $curtime);

  my $sleeptime = 0;
  my $prl;
  my $prls;
  my (@returls) = ();
  my ($t) = 0;
  foreach $t (sort numerically keys %retry_at) {
    $earliest = $t;
    last if ($t > $curtime);
    $prls = delete $retry_at{$t};
    foreach $prl (split(/\377/, $prls)) {
      push(@returls, $prl);
      $retry_left{$prl}--;
    }
  }
  # is it the last?
  $earliest = 0 if ($earliest <= $curtime);
  &logMsg("DEBUG: getRetryUrls: curtime = $curtime, earliest = $earliest\n");
  return (0, @returls);
}

## return 0 if last try, 1 if need to retry.
sub handleError{
    my ($prl, $host, $errnum) = @_;
    my $curtime = time;
    my $retrytime;
  
    $retry_left{$prl} = $retryObj->retryTimes($host, $errnum)
	unless defined $retry_left{$prl};

    ## logMsg("\nDEBUG: in handleError: $prl");
    ## logMsg("DEBUG: in handleError: errnum=$errnum, " . 
    ## "retry_left=$retry_left{$prl},". 
    ## $retryObj->retryTimes($host, $errnum));

    if ($retry_left{$prl} == 0) {
	delete $retry_left{$prl};
	return 0;
    }

    $retrytime = $curtime + $retryObj->retryAfter($host, $errnum);
    $earliest = $retrytime if ((!$earliest) || ($retrytime < $earliest));
    $retry_at{$retrytime} = 
	join("\377", split(/\377/, $retry_at{$retrytime}), $prl);
    logMsg("DEBUG: handleError: curtime=$curtime, " . 
	   "earliest=$earliest, retrytime=$retrytime");
    ## logMsg("DEBUG: in handleError: prls = '$retry_at{$retrytime}'\n");
    return $retry_left{$prl};
}

sub sleepFor {
    my($sleeptime) = shift;
    logMsg("Sleeping for $sleeptime seconds...");
    sleep($sleeptime);
}

sub time_stamp {
    my $timeval = shift;
    my ($sec, $min, $hr, $d, $m, $yr, $misc) = localtime($timeval);
    $m++;
    return sprintf("[%02d/%02d/%02d %02d:%02d:%02d]", 
		   $m, $d, $yr, $hr, $min, $sec);
}
1;
