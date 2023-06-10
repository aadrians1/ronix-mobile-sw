
package EWSspUrlFilterFancy;

require 5.000;

use EWSspLog;

## $debug = 1;

sub new {
    my $exprFile = $_[1];
    my $self = {};
    bless $self;
    print "exprFile = $exprFile\n" if $debug;

    ## read in the url filter file
    return undef unless $self->parseExprFile($exprFile);

    $self;
}

sub checkSyntax {
    my ($expr, $exprFile) = @_;

    eval "m#$expr#";
    if ($@) {
	print STDERR "line $., $exprFile: Error in expression '$expr': $@\n"; 
	return 0;
    }
    return 1;
}


sub addIncludeExpr {
    my $excludePattern = shift();
    my $mode = shift();
    my $regexp = shift();

    if ($mode eq "") {
	$excludePattern = "!(( (m#$regexp#)";
    }
    if ($mode eq "include") {
	$excludePattern .= " || (m#$regexp#)";
    }
    if ($mode eq "exclude") {
	$excludePattern .= ") && !( (m#$regexp#)";
    }
    return $excludePattern;
}

sub addExcludeExpr {
    my $excludePattern = shift();
    my $mode = shift();
    my $regexp = shift();

    if ($mode eq "") {
	$excludePattern = "(( (m#$regexp#)";
    }
    if ($mode eq "exclude") {
	$excludePattern .= " || (m#$regexp#)";
    }
    if ($mode eq "include") {
	$excludePattern .= " )) || (( (m#$regexp#)";
    }
    return $excludePattern;
}




## * order matters.  you're either in "include" mode or "exclude" mode.
##   each set of "includes" or "excludes" applies to the previous set.
## * if the first set is "includes", then assume that by default everything
##   is excluded.  if "excludes", then included.
##
## create an expression to return TRUE if the pattern is EXCLUDED
## 
sub parseExprFile {
    my $self = shift;
    my $exprFile = shift;

    ## OPEN FILE
    if (! open(EXPR, $exprFile)) { 
	print STDERR "Cannot open Filter Expr File '$exprFile': $!";
	return 0;
    }

    my $site = "";
    my $mode = "";    # either 'include' or 'exclude' (or nothing)
    $excludePattern = "";
    while (<EXPR>) {

	## print "EXPR: $_";
	## print "EXCL: $excludePattern\n";

	## get rid of comments
	s/^\s+//;               # leading space
	s/\#.*$//;              # comments
	s/\s+$//;               # trailing space
	next if ($_ eq '');

	## check for invalid lines
	if (!/:/) {
	    warn "Invalid line '$_'\n";
	    next;
	}

	($field, $value) = split(/\s*:\s*/, $_, 2);
	if (!checkSyntax($value, $exprFile)) {
	    return 0;
	}

	## IF SITE
	if ($field =~ /^site$/i) {

	    ## at this point $site is the PREVIOUS site.
	    ## set exclude pattern for previous site, if any.
	    if ($site && $excludePattern) {
		$excludePattern .= " ))";
		$ {$self->{siteExprDict}}{$site} = $excludePattern;
		## logMsg($excludePattern);
	    }

	    $excludePattern = "";
	    $mode = "";
	    $site = $value;
	    ## put site on object's list of sites
	    push(@{$self->{'siteOrder'}}, $site);

	    ## defaults for maxdocs, username, and passwd
	    $ {$self->{maxdocs}}{$site} = -1;
	    $ {$self->{username}}{$site} = "wedeliver";
	    $ {$self->{passwd}}{$site} = "exciting";
	}

	## USERNAME
	elsif ($field =~ /^username$/i) {
	    $ {$self->{username}}{$site} = $value;
	}
	## PASSWD
	elsif ($field =~ /^passwd$/i) {
	    $ {$self->{passwd}}{$site} = $value;
	}
	## MAX DOCS
	elsif ($field =~ /^MaxDocs$/i) {
	    if ($value !~ /^-?\d+$/) {
		print STDERR 
		    "line $., $exprFile: Error. '$value' must be integer.\n"; 
		return 0;
	    }
	    $ {$self->{maxdocs}}{$site} = $value;
	}

	## EXCLUDE
	elsif ($field =~ /^Exclude$/i) {
	    $excludePattern = addExcludeExpr($excludePattern, $mode, $value);
	    $mode = "exclude";
	} 

	## INCLUDE
	elsif ($field =~ /^Include$/i) {
	    $excludePattern = addIncludeExpr($excludePattern, $mode, $value);
	    $mode = "include";
	}
	
	## NONE OF THE ABOVE
	else {
	    print STDERR "line $., $exprFile: Unknown field name '$field'.";
	    return 0;
	}
    }

    ## last site
    if ($site && $excludePattern) {
	$excludePattern .= " ))";
	$ {$self->{siteExprDict}}{$site} = $excludePattern;
	## logMsg($excludePattern);
    }

    ## print "\n"; print "\n";
    if (0) {
	foreach $site (sort keys %{$self->{siteExprDict}}) {
	    print "$site\n";
	    print "$ {$self->{siteExprDict}}{$site}\n\n";
	}
	exit;
    }

    1;
}

## AUTHORIZATION INFO
sub usernameForHost {
    my $self = shift();
    my $host = shift();
    $host = "http://$host";
    my $username = $ {$self->{username}}{$host};

    $KLUGE=1;
    if ($KLUGE) {
	if ($host eq "http://cause-www.colorado.edu" ||
	    $host eq "http://www.intertower.com" ||
	    $host eq "http://www.iwol.com" ||
	    $host eq "http://www.nfl.com" ||
	    $host eq "http://websight.com") 
	{
	    $username = "";
	}
    }

    return $username;
}
sub passwdForHost {
    my $self = shift();
    my $host = shift();
    $host = "http://$host";
    my $passwd = $ {$self->{passwd}}{$host};
    $KLUGE=1;
    if ($KLUGE) {
	if ($host eq "http://cause-www.colorado.edu" ||
	    $host eq "http://www.intertower.com" ||
	    $host eq "http://www.iwol.com" ||
	    $host eq "http://www.nfl.com" ||
	    $host eq "http://websight.com") 
	{
	    $passwd = "";
	}
    }
    return $passwd;
}

sub maxDocsForHost {
    my $self = shift();
    my $host = shift();
    $host = "http://$host";
    my $docs = $ {$self->{maxdocs}}{$host};
    return $docs;
}


## unused???
sub isValid {
    my $self = shift();
    return $self->{'siteOrder'};
}

sub excluded {
    my $self = shift();
    my $site = shift();
    my $path = shift();

    my $expr = $self->getExpr($site);
    ## logMsg("EXCLUDE?  $site/$path");

    $_ = $path;
    if (0) {
	if ($path =~ /\./) {
	    print "$path\n";
	    print "$expr\n\n";
	}
    }
    eval "($expr);" ;
}

sub included {
    my $self = shift;
    my $site = shift;
    my $path = shift;

    my $expr = $self->getExpr($site);
    
    $_ = $path;
    return (!eval "($expr);") ;
}

sub getExpr {
    my $self = shift;
    my ($site) = @_;
    my $site_regexp;

    foreach $site_regexp (@{$self->{'siteOrder'}}) {
	## print "SITE: $site_regexp\n" if $debug;
	if ($site =~ m#$site_regexp#) {
	    ## print "SITE: $site_regexp\n";
	    ## print "${$self->{'siteExprDict'}}{$site_regexp}\n";
	    return ${$self->{'siteExprDict'}}{$site_regexp};
	}
    }
    return "";
}

sub debugPrint {
    my $self = shift;
    my $site_regexp;

    foreach $site_regexp (@{$self->{'siteOrder'}}) {
	print "\nSITE: $site_regexp\n";
	print "EXPR: ${$self->{'siteExprDict'}}{$site_regexp}\n";
    }
}

1;
