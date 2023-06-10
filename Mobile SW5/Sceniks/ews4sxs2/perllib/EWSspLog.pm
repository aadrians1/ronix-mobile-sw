
package EWSspLog;

require 5.000;
require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(logMsg warningMsg errorMsg fatalMsg logTimestamp);


#$nNotes = 0;
#$nErrors = 0;
#$nWarnings = 0;

sub new {
    my ($logFile, $restart) = @_;

    #$nNotes = 0;
    #$nErrors = 0;
    #$nWarnings = 0;
    
    my $fname = (($restart) ? ">" : "" ) . "> $logFile";

    open(LOG, $fname) 
	|| die "Cannot open Log File '$logFile': $!";

    select((select(LOG), $| = 1)[0]);
    my ($sec, $min, $hr, $d, $m, $yr, $misc) = localtime(time);
    $m++;
    my $tstamp = 
	sprintf("[%02d/%02d/%02d %02d:%02d:%02d]", 
		$m, $d, $yr, $hr, $min, $sec);
    if ($restart) {
	print LOG "##\n## RESTARTED at: $tstamp\n##\n";
    }
    else {
	print LOG "##\n## STARTED at: $tstamp\n##\n";
    }
}

sub warningMsg {
    print LOG "WARN: @_\n";
    #$nWarnings++;
}

sub errorMsg {
    print LOG "ERROR: @_\n";
    #$nErrors++;
}

sub fatalMsg {
    print LOG "FATAL Error: Cannot Proceed. @_\n";
    $spiderNum = $ENV{'SPIDER_HOME'};
    @parts = split("/", $spiderNum);
    $spiderNum = $parts[$#parts];
    system("echo '$spiderNum: @_' | Mail mark\@excite.com");
    exit 1;
}

sub logMsg {
    print LOG "@_\n";
    #$nNotes++;
}

sub logTimestamp {
    my ($sec, $min, $hr, $d, $m, $yr, $misc) = localtime(time);
    $m++;
    logMsg("[TIME $hr:$min:$sec $m/$d/$yr]: @_");
}

sub summaryLog {
    print STDERR "Encountered $nErrors Error(s), $nWarnings Warning(s).\n";
    logMsg("Encountered $nErrors Error(s), $nWarnings Warning(s).");
}
1;
