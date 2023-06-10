
### NOTE: not really an object.  just a package.

package AddrDb;

use EWSspLog;

########################################################################

####
## ACCESSING INFO
## getAddrFor()
## getHosts()

####
## MODIFYING INFO
## refreshDb()
## setAddrFor()

####
## DEFAULTS
## setDefLoadFile()
## setDefSaveFile()

####
## DEFAULT LOADING/SAVING
## loadDb()
## saveDb()

####
## CONFIGURABLE LOADING/SAVING
## loadAddrsFromFile()  -- can ADD to present in-core DB
## saveAddrsToFile()

########################################################################

sub refreshDb {
    %ADDRS = ();
}

sub setDefLoadFile {
    my $filename = shift();
    $filename = $main::addr_db_infile if (!$filename);
    $LOADFILE = $filename;
}

sub setDefSaveFile {
    my $filename = shift();
    $filename = $main::addr_db_outfile if (!$filename);
    $SAVEFILE = $filename;
}

sub getHosts {
    return (sort keys %ADDRS);
}

sub getAddrFor {
    my $host = shift();
    return $ADDRS{$host};
}

sub setAddrFor {
    my $host = shift();
    my $addr = shift();
    $ADDRS{$host} = $addr;
}

sub saveAddrsToFile {
    my $outfile = shift();
    open(ADDR_OUT, ">$outfile")
	|| warningMsg("Couldn't open $outfile for writing.");
    @hosts = getHosts();
    foreach $host (@hosts) {
	$addr = getAddrFor($host);
	print ADDR_OUT "$host\t$addr\n";
    }
    close(ADDR_OUT);
}

sub saveDb {
    setDefSaveFile() if ($SAVEFILE == undef);
    saveAddrsToFile($SAVEFILE);
}

sub loadAddrsFromFile {
    my $infile = shift();
    open(ADDR_IN, $infile)
	|| warningMsg("Couldn't open $infile for reading.");
    while(<ADDR_IN>) {
	chop;
	($host, $addr) = split(" ", $_);
	setAddrFor($host, $addr);
    }
    close(ADDR_IN);
}

sub loadDb {
    setDefLoadFile() if ($LOADFILE == undef);
    loadAddrsFromFile($LOADFILE);
}


1;
