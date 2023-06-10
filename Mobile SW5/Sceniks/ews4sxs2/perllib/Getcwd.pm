package Getcwd;
require 5.000;
require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(getcwd);

# By Brandon S. Allbery
#
# Usage: $cwd = getcwd();

sub getcwd
{
    local($dotdots, $cwd, @pst, @cst, $dir, @tst);

    unless (@cst = stat('.'))
    {
	warn "stat(.): $!";
	return '';
    }
    $cwd = '';
    do
    {
	$dotdots .= '/' if $dotdots;
	$dotdots .= '..';
	@pst = @cst;
	unless (opendir(PARENT, $dotdots))
	{
	    warn "opendir($dotdots): $!";
	    return '';
	}
	unless (@cst = stat($dotdots))
	{
	    warn "stat($dotdots): $!";
	    closedir(PARENT);
	    return '';
	}
	if ($pst[0] == $cst[0] && $pst[1] == $cst[1])
	{
	    $dir = '';
	}
	else
	{
	    do
	    {
		unless ($dir = readdir(PARENT))
		{
		    warn "readdir($dotdots): $!";
		    closedir(PARENT);
		    return '';
		}
		unless (@tst = lstat("$dotdots/$dir"))
		{
		    warn "lstat($dotdots/$dir): $!";
		    closedir(PARENT);
		    return '';
		}
	    }
	    while ($dir eq '.' || $dir eq '..' || $tst[0] != $pst[0] ||
		   $tst[1] != $pst[1]);
	}
	$cwd = "$dir/$cwd";
	closedir(PARENT);
    } while ($dir);
    chop($cwd);
    $cwd;
}

1;

