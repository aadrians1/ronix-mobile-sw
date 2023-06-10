package Getopt;
require 5.000;
require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(Getopt);

# $RCSfile: getopt.pl,v $$Revision: 4.1 $$Date: 92/08/07 18:23:58 $

# Process single-character switches with switch clustering.  Pass one argument
# which is a string containing all switches that take an argument.  For each
# switch found, sets $opt_x (where x is the switch name) to the value of the
# argument, or 1 if no argument.  Switches which take an argument don't care
# whether there is a space between the switch and the argument.

# Usage:
#	use Getopt;
#	Getopt('oDI');  # -o, -D & -I take arg.  Sets opt_* as a side effect.

sub Getopt {
    local($argumentative) = @_;
    local($_,$first,$rest);

    while (@ARGV && ($_ = $ARGV[0]) =~ /^-(.)(.*)/) {
	($first,$rest) = ($1,$2);
	if (index($argumentative,$first) >= 0) {
	    if ($rest ne '') {
		shift(@ARGV);
	    }
	    else {
		shift(@ARGV);
		$rest = shift(@ARGV);
	    }
	    eval "\$opt_$first = \$rest;";
	}
	else {
	    eval "\$opt_$first = 1;";
	    if ($rest ne '') {
		$ARGV[0] = "-$rest";
	    }
	    else {
		shift(@ARGV);
	    }
	}
    }
}

1;

