
package EWSspRetryLogic;

require 5.000;

##
## ERROR CODES
##   500 -- Internal Server Error
##   501 -- Not Implemented    <-- this should never happen
##   502 -- Bad Gateway
##   503 -- Service Unavailable -- check the Retry-After field for info
##   504 -- Gateway Timeout
##   505 -- HTTP Version Not Supported   <-- nor this
##
##  1000 -- Timed out
##  1001 -- Bad HTTP response
##  1002 -- Can't get address
##  1003 -- Can't connect
##  1004 -- Can't get/bind socket
##  1005 -- Socket/File Read Failed
##  1006 -- Can't write to file
##  1007 -- Bad relocation information
##

sub new {
    my $exprFile = $_[1];
    my $self = {};
    bless $self;
    print "Retry exprFile = $exprFile\n" if $debug;
    return undef unless $self->parseExprFile($exprFile);
    $self;
}

sub parseExprFile {
    my $retry_times;
    my $retry_times_default = 2;
    my $self = shift;
    my $exprFile = shift;
    if (! open(EXPR, $exprFile)) { 
	print STDERR "Cannot open Filter Expr File '$exprFile': $!";
	return 0;
    }

    while (<EXPR>) {
	next if /^\s*\#/;
	s/\#.*$//;              # comments
	s/^\s+//;               # leading space
	s/\s+$//;               # trailing space
	next if ($_ eq '');
	if (!/:/) {
	    warn "Invalid retryLogic line '$_'\n";
	    next;
	}
	($field, $value) = split(/\s*:\s*/, $_, 2);

	if ($field =~ /^site$/i) {
	    #set $site
	    $site = $value;
	    $retry_times = $retry_times_default;
	    push(@{$self->{'siteOrder'}}, $site);
	    %{$self->{'siteExprDict'}{$site}} = ();
	    eval "m!$value!";
	    if ($@) {
		print STDERR "Error in Epression: line $., $exprFile: $@\n"; 
		return 0;
	    }
	}
	elsif ($field =~ /^retry-times$/i) {
	    $retry_times = $value;
	    if ($value !~ /\d+/) {
		print STDERR 
		    "line $., $exprFile: Error in RetryTimes Value: $value\n";
		return 0;
	    }
	}
	else {
	    ### Error Codes ###
	    eval "m!$field!";
	    if ($@) {
		print STDERR "Error in Epression: line $., $exprFile: $@\n"; 
		return 0;
	    }

	    ## if ($value !~ /\d+\s*:\s*\d+/) {}
	    if ($value !~ /\d+/) {
		print STDERR 
		    "line $., $exprFile: Error in RetryAfter Value: $value\n";
		return 0;
	    }

	    $ {$ {$self->{'siteExprDict'}}{$site}}{$field} = 
		"$retry_times:$value";
	}
    }
    1;
}

sub isValid {
    my $self = shift;
    return $self->{'siteOrder'};
}

sub retryTimes {
    my $self = shift;
    my ($site, $errnum) = @_;
    
    $retryExpr = $self->retryEntries($site, $errnum);
    ($times2retry, $minutes) = split(":", $retryExpr);
    return $times2retry;
}

sub retryAfter {
    my $self = shift;
    my ($site, $errnum) = @_;
    
    ## return in seconds
    $retryExpr = $self->retryEntries($site, $errnum);
    ($times2retry, $minutes) = split(":", $retryExpr);
    return ($minutes * 60);
}

sub retryEntries {
    my $self = shift;
    my ($site, $errnum) = @_;
    my $siter;
    my $erriter;

    foreach $siter (@{$self->{'siteOrder'}}) {
	print "SITE: $siter\n" if $debug;
	if ($site =~ m!$siter!) {
	    foreach $erriter (keys %{$ {$self->{'siteExprDict'}}{$siter}}) {
		print "ERR EXPR: $erriter\n" if $debug;
		return $ {$ {$self->{'siteExprDict'}}{$siter}}{$erriter} 
		if ($errnum =~ m!$erriter!);
	    }
	}
    }
    return "0:0";
}

1;

