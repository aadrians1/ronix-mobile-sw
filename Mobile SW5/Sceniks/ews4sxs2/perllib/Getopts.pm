package Getopts;
require 5.000;
require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(Getopts);

# getopts.pl - a better getopt.pl

# Usage:
#	use Getopts;
#	Getopts('a:bc');	# -a takes arg. -b & -c not. Sets opt_* as a
#				#  side effect.

sub Getopts {
    local($argumentative) = @_;
    local(@args,$_,$first,$rest);
    local($errs) = 0;
    local $Exporter::ExportLevel;

    @args = split( / */, $argumentative );
    while(@ARGV && ($_ = $ARGV[0]) =~ /^-(.)(.*)/) {
	($first,$rest) = ($1,$2);
	$pos = index($argumentative,$first);
	if($pos >= 0) {
	    if($args[$pos+1] eq ':') {
		shift(@ARGV);
		if($rest eq '') {
		    ++$errs unless @ARGV;
		    $rest = shift(@ARGV);
		}
		eval "\$opt_$first = \$rest;";
		push( @EXPORT, "\$opt_$first" );
	    }
	    else {
		eval "\$opt_$first = 1";
		push( @EXPORT, "\$opt_$first" );
		if($rest eq '') {
		    shift(@ARGV);
		}
		else {
		    $ARGV[0] = "-$rest";
		}
	    }
	}
	else {
	    print STDERR "Unknown option: $first\n";
	    ++$errs;
	    if($rest ne '') {
		$ARGV[0] = "-$rest";
	    }
	    else {
		shift(@ARGV);
	    }
	}
    }
    $Exporter::ExportLevel++;
    import Getopts;
    $errs == 0;
}

1;

