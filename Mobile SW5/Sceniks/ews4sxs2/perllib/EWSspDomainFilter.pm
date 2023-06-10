
package EWSspDomainFilter;

use EWSspLog;
use EWShttp;

require 5.000;

sub new {
  my $exprFile = $_[1];  ## grabs arg
  my $self = {};
  bless $self;
  return undef unless $self->parseDomainExprFile($exprFile);
  $self;
}

sub parseDomainExprFile {
    my $self = shift;
    my $exprFile = shift;

    if (! open(EXPR, $exprFile)) {
	errorMsg("Cannot open Filter Expr File $exprFile: $!");
	return 0;
    }
    while (<EXPR>) {
	next if /^\s*\#/;
	s/\#.*$//;              # comments
	s/^\s+//;               # leading space
	s/\s+$//;               # trailing space
	next if ($_ eq '');

	eval q#m|$_|#;

	if ($@) {
	    errorMsg("Error in Expression: $exprFile, line $.: $@"); 
	    return 0;
	}

	if (/.*:\d+\$/) {
	    ## ($domain, $port) = split(":", $_);
	    $domainAndPort = $_;
	} else {
	    chop($_);
	    $domainAndPort = "$_:80\$";
	}
	## print "$domainAndPort\n";
	push (@{$self->{'domainList'}}, $domainAndPort);
    }
    close(EXPR);
    return 1;
}

sub isValid {
  my $self = shift;
  return (@{$self->{'domainList'}} != 0); #return scalar??
}

sub included {
    my $self = shift;
    my $name = shift;

    if ($name =~ /www\.seattletimes\.com/) {
	return 0;
    }

    foreach $expr (@{$self->{'domainList'}}) {
	#print "expr : $expr\n";
	## return 1 if ($name =~ m|^$expr$|);
	return 1 if ($name =~ m|$expr|);
    }

    ## # Try IP names.
    ## $name = EWShttp::ipAddrByName($name);
    ## return 0 unless $name;
    ##
    ## foreach $expr (@{$self->{'domainList'}}) {
    ##   #print "expr : $expr\n";
    ##   return 1 if ($name =~ m|$expr|);
    ## }

    return 0;
}

1;

