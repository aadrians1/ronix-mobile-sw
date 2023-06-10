
package ComLine;

sub existsFlag {
    my ($flag) = @_;
    argPosition($flag);
}

sub argPosition {
    my ($flag) = @_;

    my ($argNum) = 0;
    @FILE_ARGS = @main::ARGV;
    while ($argNum <= $#FILE_ARGS) {
	return ($argNum+1) if ($FILE_ARGS[$argNum] eq $flag);
	$argNum++;
    }
    return 0;
}

sub getFlagVal {
    my ($flag, $default) = @_;

    my($val) = $default;
    my($argNum) = argPosition($flag);

    if ($argNum) { 
	$val = $FILE_ARGS[$argNum];
	if ($val =~ /\/$/) {
	    chop($val);
	}
    }
    return $val;
}

1;
