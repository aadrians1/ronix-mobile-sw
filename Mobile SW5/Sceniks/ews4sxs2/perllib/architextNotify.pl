## Copyright (c) 1996 Excite, Inc.

package ArchitextNotify;

use Socket; 

$magic      = "socket00000";
$socket     = "";

  $root = "/usr/local/www/scenix.com/ews4sxs2";
require 'architextConf.pl';
%attr = &ArchitextConf'readConfig("$root/Architext.conf");

sub notify {
    #
    # takes the name of the collection to notify for
    # returns 1 if successful, 0 otherwise
    #

    local ($col, $subsc) = @_;
    local ($err, $body, $server, $cgdir, $email, $port, %col_attr);

    %col_attr = &ArchitextConf'readConfig("$root/Architext.conf", $col);

    $port = $ENV{'SERVER_PORT'} || $col_attr{'ServerPort'};
    $server = $attr{'ServerName'};
    $server = $server . ":" . $port if ($port);
    $cgdir  = $attr{'ServerCgi'};
    $email = $col_attr{'AdminMail'};

    $path = "/cgi/EWSN-update.cgi?server=$server&collection=$col&cgidir=$cgdir&subsc=$subsc";
    ($err, $body) = &getURL('www.atext.com', 80, $path, $email);
    return 0 if $err;
    return 1;	
}

## return (error, body) where error is "" on success

sub getURL {
    local ($host, $port, $path, $email, $timeout, $mode) = @_;
    local ($retval);
    $retval = eval { &get_impl($host, $port, $path, $email, $timeout, $mode) };
    alarm(0);
    $SIG{'ALRM'} = 'IGNORE';
    return ($@, "") if $@;
    return ("", $retval);
}

sub get_impl {
    local ($host, $port, $path, $email, $timeout, $mode) = @_;
    local ($addr, $name, $aliases, $addrtype, $length, $here, $there);
    local ($respcode, $respmesg, $headers, $query, $retval);
    local (%def_hdr);
    local ($/);


    $socket = $magic++;
    $timeout = 180 if (!$timeout);
    $mode = "HTTP/1.0" if (!$mode);
    $mode = "" if $mode eq '*';
    %def_hdr = ('User-agent', "architext_notifier_ews", 'From', $email);

    ## Get a socket and bind it.
    socket($socket, &AF_INET, &SOCK_STREAM, 0)
	|| &throw($socket, "Couldn't get socket: $!");
    $here = pack('S n a4 x8', &AF_INET, 0, pack('c4', 0, 0, 0, 0));
    bind($socket, $here)
	|| &throw($socket, "Can't bind socket: $!");

    $SIG{'ALRM'} = '&timeout';
    alarm($timeout);

    ($name, $aliases, $addrtype, $length, $addr) = gethostbyname($host);
    ## print "$name,  $aliases, $addrtype, $length, $addr";
    die "Couldn't get address for '$host'" if (!$addr);

    $there = pack('S n a4 x8', &AF_INET, $port, $addr);

    connect($socket, $there)
	|| &throw($socket, "Can't connect: $!");

    alarm($timeout);
    select((select($socket), $|=1)[0]);

    $query = "GET $path $mode";
    $query =~ s/\s+$//;
    print {$socket} "$query\r\n";
    for (keys %{def_hdr}) {
	print {$socket} "$_: ", $def_hdr{$_}, "\r\n";
    }
    print {$socket} "\r\n";
    alarm($timeout);

    if ($mode) {
	$/ = "\n";
	$_ = <$socket>;
	die "Bad HTTP response ($_)" unless  m|^HTTP\S*\s+(\d+)\s+(.*)$|;
	($respcode, $respmesg) = ($1, $2);
	while (<$socket>) {
	    alarm($timeout);
	    last if /^[\r\n]+$/;
	    $headers .= $_;
	}
	if ($respcode == 200) {
	    undef $/;
	    $retval = <$socket>;
	} else {
	    &throw($socket, "HTTP error: $respcode $respmesg");
	}
    } else {
	undef $/;
	$retval = <$socket>;
    }
    close($socket);
    $socket = "";
    return $retval;
}

sub throw {
    local ($h, $mesg) = @_;
    close($h) if $h;
    die $mesg;
}

sub timeout {
    close($socket) if $socket;
    die "Timed out\n";
}


1;


