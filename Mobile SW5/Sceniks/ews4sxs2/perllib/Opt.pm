package Opt;

require 5.000;
require Exporter;
@ISA = (Exporter);
@EXPORT = ();
@EXPORT_OK = qw(get1 get2 simple1 simple2 gather flag);

sub get1 {
    my($rx, @def) = @_;
    my(@argv, @all, @match);

    for (@main::ARGV) {
	if (/$rx/) {
	    @match = /$rx/;
	    shift(@match) until $match[0] || $#match < 0;
	    @match = (1) unless @match;
	    push(@all, @match);
	} else {
	    push(@argv, $_);
	}
    }
    @main::ARGV = @argv;
    @all = @def unless @all;

    wantarray ? @all : $all[$#all];
}

sub get2 {
    my($rx, $val) = @_;
    my(@argv);

    while (@main::ARGV) {
	$arg = shift @main::ARGV;
	if ($arg =~ /$rx/) {
	    $val = shift @main::ARGV;
	} else {
	    push(@argv, $arg);
	}
    }

    @main::ARGV = @argv;
    $val;
}

sub flag {
    my($rx, @def) = @_;
    get1("^$rx\$", @def);
}

sub simple1 {
    my($rx, @def) = @_;
    get1("^$rx" . '(.*)$', @def);
}

sub simple2 {
    my($rx, $def) = @_;
    get2("^$rx" . '$', $def);
}

sub gather {
    my($regexp) = @_;
    my(@result);

    @result = grep(/$regexp/, @main::ARGV);
    @main::ARGV = grep(!/$regexp/, @main::ARGV);
    @result;
}

1;
