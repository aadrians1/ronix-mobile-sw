## Routines to help read Architext configuration files

package ArchitextConf;

## Reads a tag from a configuration file. Not very flexible in terms
## of config file format.
sub readTag {
    local($conffile, $tag, $tagname) = @_;
    local(*CONF, $regexp, $lastkey, $key, $val, %attributes);
    local($tagdepth);

    $regexp = "$tag $tagname";
    $regexp =~ s/\s+$//;
    $regexp = "<$regexp>";

    die "Can't read configuration file '$conffile'" if (! -r $conffile);
    open(CONF, $conffile) || die "Can't open $conffile";
    while (<CONF>) {
	chop;
	s/#.*$//;
	next if /^\s*$/;
	if (/^<([^<>]+)>\s*$/) {
	    ## Push the current tag onto the stack.
	    push(@tagstack, $1);
	    $lastkey = "";
	} elsif (/^<(\/[^<>])+>\s*/) {
	    ## It's a closing tag. Does it match?
	    $closetag = $1;
	    if (!@tagstack) {
		warn "Closing tag '$closetag' without opening tag\n";
	    } elsif ($tagstack[$#tagstack] !~ /^$closetag/) {
		warn "Closing tag '$closetag' does not match current " .
		     "open tag '$tagstack[$#tagstack]'\n";
	    } else {
		pop(@tagstack);
	    }
	    $lastkey = "";
	} elsif (!@tagstack ||
		 $tagstack[$#tagstack] eq join(" ", $tag, $tagname)) {
	    ## Here's some non-tag text. Is it enclosed by the tag
	    ## we're looking for?
	    if (/^\s+/ && $lastkey) {
		## Special case: indention is addition to previous
		## line.
		$attributes{$lastkey} .= $_;
		next;
	    }
	    ($key, $val) = split(/\s+/, $_, 2);
	    $attributes{$key} = $val;
	    $lastkey = $key;
	}
    }

    %attributes;
}

## This function takes a configuration-file name or directory and a
## database name. It reads all the configuration options both from
## $config (or $config/Architext.conf if $config is a directory) and
## $database.conf in the root directory.
sub readConfig {
    local($config, $database) = @_;
    local(%attr);
    if (-d $config) {
	$config = "$config/Architext.conf";
    }
    die "Can't read configuration file '$config'" unless -r $config;
    %attr = &readTag($config, "Collection", $database);
    if ($attr{'ArchitextRoot'}) {
	$dbconfig = $attr{'ArchitextRoot'} . "/collections/$database.conf";
	if (-r $dbconfig) {
	    %attr = (%attr, &readTag($dbconfig, "Collection", $database));
	}
    }
    %attr;
}

## Takes a path and an optional root path, and makes an absolute path
## if the original path was relative.
sub makeAbsolutePath {
    local($path, $root) = @_;
    ## second part of the 'and' is for NT pathnames
    if (($path !~ m|^/|) && ($path !~ m|^\w\:|)) {
	if ($root) {
	    chop($root) if $root =~ m|/$|;
	    $path = "$root/$path";
	}
	print STDERR "Warning: relative path '$path' specified"
	    if (($path !~ m|^/|) && ($path !~ m|^\w\:|));
    }
    $path;
}

## Takes a set of configuration options and makes them into a
## CollectionInfo file (i.e., a file to pass to our executables with
## the -C flag).
sub makeInfoFile {
    local(%attr) = @_;

    ## First check to see that all the stuff is there.

    $attr{'CollectionRoot'} ||
	die "Can't create dbinfo file: no CollectionRoot specified\n";

    $attr{'StemTable'} ||
	die "Can't create dbinfo file: no StemTable specified\n";

    $attr{'StopTable'} ||
	die "Can't create dbinfo file: no StopTable list specified\n";

    $attr{'CollectionInfo'} ||
	die "Can't create dbinfo file: no CollectionInfo file specified\n";

    open(OUT, ">$attr{'CollectionInfo'}") ||
	die "Can't open CollectionInfo file '$attr{'CollectionInfo'}' " .
	    "for output\n";

    $stem = &makeAbsolutePath($attr{'StemTable'}, $attr{'ArchitextRoot'});
    $stop = &makeAbsolutePath($attr{'StopTable'}, $attr{'ArchitextRoot'});

    print OUT "-R $attr{'CollectionRoot'}\n";
    print OUT "-stem $stem\n";
    print OUT "-stop $stop\n";
    print OUT "-pidfile $attr{'PidFile'}\n" if $attr{'PidFile'};
    print OUT "-nostem\n" if $attr{'NS'}; 
    close OUT;
}

1;
