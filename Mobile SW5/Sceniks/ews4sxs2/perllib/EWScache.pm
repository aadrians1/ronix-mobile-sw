
package EWScache;

## when we say "url", we REALLY mean "prl"
##   $proto, $addr, $port, $path, $host  -- but TABS, not commas
##   eg.: http  206.66.71.136   80   /index.html   www.excite.com

###
##
## exports:
##   new          ( [<filename>] )         -- ctor; opt. takes input file
##   readInFile   ( <filename> )           -- read data in
##   dumpSelf     ( [<file>] )             -- print data; to file, if given
##   status4Url   ( <url> [,<new value>] ) -- get/set status
##   time4Url     ( <url> [,<new value>] ) -- get/set time
##   linksRef4Url ( <url> [,<new value>] ) -- get/set ref to LoLinks
##
###


use EWStime;

sub new {
    my $self = {};
    bless $self;
    shift();
    my $infile = shift();
    $self->readInFile($infile) if $infile;
    return $self;
}

sub readInFile {
    my $self = shift();
    my $infile = shift();
    open(IN, "$infile") or die "bobo file: $infile";
    while(<IN>) {
	chop;
	if ($_ ne "") {
	    push(@lines, $_);
	} else {
	    my ($url, $status, $timeStr, @links) = @lines;
	    ## $self->{url}{$url} = [ 0, $timeStr, \@links ];
	    $self->status4Url($url, 0);
	    $self->time4Url($url, $timeStr);
	    ## $self->linksRef4Url($url, \@links);
	    foreach $link (@links) {
		$self->addLink4Url($url, $link);
	    }
	    @lines = ();
	}
    }
    if (@lines) {
	my ($url, $status, $timeStr, @links) = @lines;
	## $self->{url}{$url} = [ 0, $timeStr, \@links ];
	$self->status4Url($url, 0);
	$self->time4Url($url, $timeStr);
	## $self->linksRef4Url($url, \@links);
	foreach $link (@links) {
	    $self->addLink4Url($url, $link);
	}
	@lines = ();
    }

    close(IN);
    return $self;
}

sub dumpSelf {
    my ($self, $outfile) = @_;
    if ($outfile) {
	open(OUT, ">$outfile") or die "bobo outfile: $outfile";
    }

    my ($str, $status, $timeStr);
    ## my $separator = " \# ";
    my $separator = "\n";
    foreach $url (sort keys %{$self->{url}}) {
	$status = $self->status4Url($url);
	if ($status == 200 || $status == 304) {
	    $timeStr = $self->time4Url($url);
	    ## HERE
	    $str = $url . $separator ."code:$status" . $separator . $timeStr;
	    my $linksListRef = $self->linksRef4Url($url);
	    foreach $link (@$linksListRef) {
		$str .= $separator . $link;
	    }
	    $str .= "\n" . (($separator eq "\n") ? "\n" : "");
	    $outfile ? print OUT $str : print $str;
	}
    }

    close(OUT) if $outfile;
}


sub removeUrl {
    my $self = shift();
    my $url = shift();
    delete $self->{url}{$url};
}

## if url not found --> return 404.
sub status4Url {
    my $self = shift();
    my $url = shift();
    my $newVal = shift();
    my $ref = \$self->{url}{$url}[0];
    $$ref = $newVal if $newVal;
    $$ref ? $$ref : 404;
}

## if url not found --> return The Epoch.
sub time4Url {
    my $self = shift();
    my $url = shift();
    my $newVal = shift();
    my $ref = \$self->{url}{$url}[1];
    if ($newVal) {
	$$ref = (($newVal =~ /^\d+$/) 
		 ? EWStime::getHttpTime($newVal) : $newVal);
    }
    $$ref ? $$ref : "Thu, 1 Jan 1970 00:00:00 GMT";
}

## if url not found --> return reference to empty list.
sub linksRef4Url {
    my $self = shift();
    my $url = shift();
    my $newVal = shift();
    my $ref = \$self->{url}{$url}[2];
    $$ref = $newVal if $newVal;
    $$ref ? $$ref : [ ];
}

sub addLink4Url {
    my $self = shift();
    my $url = shift();
    my $link = shift();
    my $listRefRef = \$self->{url}{$url}[2];
    if ($link) {
	push(@$$listRefRef, $link);
    }
    return $$listRefRef;
}

########################################################################

sub remove0s {
    my $self = shift();
    foreach $prl (keys %{$self->{url}}) {
	if ($self->status4Url($prl) == 0) {
	    delete $self->{url}{$prl};
	}
    }
}

sub traverseTree {
    my $self = shift();
    my $prl = shift();

    $status = $self->status4Url($prl);
    if ($status == 0) {
	$self->status4Url($prl, 304);
    }
    
    ## traverse tree
    $childrenRef = $self->linksRef4Url($prl);
    foreach $child (@$childrenRef) {
	traverseTree($child);
    }
}

1;
