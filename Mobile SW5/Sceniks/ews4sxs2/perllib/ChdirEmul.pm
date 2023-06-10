package ChdirEmul;
require 5.000;
require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(chdir);

# pwd.pl - keeps track of current working directory in PWD environment var
#
# $RCSfile: pwd.pl,v $$Revision: 4.1 $$Date: 92/08/07 18:24:11 $
#
# $Log:	pwd.pl,v $
#
# Usage:
#	use ChdirEmul;
#	chdir $newdir;

if ($ENV{'PWD'}) {
    local($dd,$di) = stat('.');
    local($pd,$pi) = stat($ENV{'PWD'});
    if (!defined $dd or !defined $pd or $di != $pi or $dd != $pd) {
	chop($ENV{'PWD'} = `pwd`);
    }
}
else {
    chop($ENV{'PWD'} = `pwd`);
}
if ($ENV{'PWD'} =~ m|(/[^/]+(/[^/]+/[^/]+))(.*)|) {
    local($pd,$pi) = stat($2);
    local($dd,$di) = stat($1);
    if (defined $pd and defined $dd and $di == $pi and $dd == $pd) {
	$ENV{'PWD'}="$2$3";
    }
}

sub chdir {
    local($newdir) = shift;
    if (chdir $newdir) {
	if ($newdir =~ m#^/#) {
	    $ENV{'PWD'} = $newdir;
	}
	else {
	    local(@curdir) = split(m#/#,$ENV{'PWD'});
	    @curdir = '' unless @curdir;
	    foreach $component (split(m#/#, $newdir)) {
		next if $component eq '.';
		pop(@curdir),next if $component eq '..';
		push(@curdir,$component);
	    }
	    $ENV{'PWD'} = join('/',@curdir) || '/';
	}
    }
    else {
	0;
    }
}

1;

