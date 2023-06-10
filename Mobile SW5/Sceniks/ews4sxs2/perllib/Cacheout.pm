package Cacheout;
require 5.000;
require Exporter;
use Carp;

@ISA = qw(Exporter);
@EXPORT = qw(cacheout);

# Open in their package.

sub open {
    my $pack = caller(1);
    open(*{$pack . '::' . $_[0]}, $_[1]);
}

sub close {
    my $pack = caller(1);
    close(*{$pack . '::' . $_[0]});
}

# But only this sub name is visible to them.

sub cacheout {
    ($file) = @_;
    if (!$isopen{$file}) {
	if (++$numopen > $maxopen) {
	    local(@lru) = sort {$isopen{$a} <=> $isopen{$b};} keys(%isopen);
	    splice(@lru, $maxopen / 3);
	    $numopen -= @lru;
	    for (@lru) { &close($_); delete $isopen{$_}; }
	}
	&open($file, ($saw{$file}++ ? '>>' : '>') . $file)
	    || croak "Can't create $file: $!";
    }
    $isopen{$file} = ++$seq;
}

$seq = 0;
$numopen = 0;

if (open(PARAM,'/usr/include/sys/param.h')) {
    local($.);
    while (<PARAM>) {
	$maxopen = $1 - 4 if /^\s*#\s*define\s+NOFILE\s+(\d+)/;
    }
    close PARAM;
}
$maxopen = 16 unless $maxopen;

1;

