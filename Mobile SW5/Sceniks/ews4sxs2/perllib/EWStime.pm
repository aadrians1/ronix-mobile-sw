
package EWStime;

@daysOfWeek = (Sun,Mon,Tue,Wed,Thu,Fri,Sat);
@monthsOfYear = (Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec);
%mon2Num = (Jan,0,Feb,1,Mar,2,Apr,3,May,4,Jun,5,
	    Jul,6,Aug,7,Sep,8,Oct,9,Nov,10,Dec,11);

sub new {
    my $self = {};
    bless $self;
    $self;
}

## example string: "Wed, 18 Sep 1996 15:02:24 GMT"
sub getHTTPTime {
    my $self = shift();
    my ($sec, $min, $hr, $mday, $mon, $yr, $wday, $misc) = gmtime(time);

    foreach $item ($hr, $min, $sec) {
	$item = "0$item" if $item < 10;
    }

    $HTTPtime = 
	"$daysOfWeek[$wday], $mday $monthsOfYear[$mon] $yr $hr:$min:$sec GMT";
    return $HTTPtime;
}

sub cmpTimes {
    my $self = shift();
    my $t0 = shift();
    my $t1 = shift();

    $t0 = $self->convertToRFC822($t0);
    $t0 = $self->rfc822toDigits($t0);

    $t1 = $self->convertToRFC822($t1);
    $t1 = $self->rfc822toDigits($t1);

    return ($t0 <=> $t1);
}


## EXAMPLES of the three formats we must understand
##  Sun, 06 Nov 1994 08:49:37 GMT   ; RFC 822, updated by RFC 1123
##  Sunday, 06-Nov-94 08:49:37 GMT  ; RFC 850, obsoleted by RFC 1036
##  Sun Nov  6 08:49:37 1994        ; ANSI C's asctime() format


sub convertToRFC822 {
    my $self = shift();
    my $inTime = shift();

    ## already in RFC 822
    if ($inTime =~ /^[a-zA-Z]+, \d\d /) {
	return $inTime;
    }

    ## in RFC 850
    if ($inTime =~ /^[a-zA-Z]+, \d\d-[a-zA-Z]{3,3}-/) {
	($wdayAndComma, $dayMonYr, $time, $other) = split(" ", $inTime);
	$wday = substr($wdayAndComma, 0, 3);
	($day, $mon, $yr) = split("-", $dayMonYr);
	$yr = "19$yr";
    }

    ## in asctime() format
    if ($inTime =~ /^[a-zA-Z]{3,3} /) {
	($wday, $mon, $day, $time, $yr) = split(" ", $inTime);
	$day = "0$day" if $day < 10;
    }

    $result = "$wday, $day $mon $yr $time GMT";
    return $result;
}


##  Sun, 06 Nov 1994 08:49:37 GMT   ; RFC 822, updated by RFC 1123

sub rfc822toDigits {
    my $self = shift();
    my $rfcTime = shift();

    ($wday, $day, $mon, $year, $time, $zone) = split(" ", $rfcTime);
    $mon = $mon2Num[$mon];
    ($hr,$min,$sec) = split(":", $time);
    $timeStr = "$year$mon$day$hr$min$sec";

    return $timeStr;
}


1;
