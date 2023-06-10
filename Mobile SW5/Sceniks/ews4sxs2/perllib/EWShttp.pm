## Architext Software (c) Copyright 1996

package EWShttp;

use Socket;
use EWSspLog;

@addr_cache = ();
%addr_cache = ();
$magic      = "socket00000";
$socket     = "";
$IPCACHE    = 1500;

sub new {
    my $type = shift;
    my $self = {};
    bless $self;
    $self->{'OutHdr'} = {};
    $self->{'socket'} = "";
    #$self->header(@_);
    $self;
}

########################################################################

sub open {
    my $self = shift;
    my ($host, $port, $path, $timeout, $mode) = @_;

    ## $host, when it gets passed in, 
    ## can be EITHER the hostname or the IP addr.

    eval { $self->open_impl($host, $port, $path, $timeout, $mode) };
    alarm(0);
    $SIG{'ALRM'} = 'IGNORE';
    if ($@) {
	$self->close();
	return "$@";
    }
    "";
}

sub open_impl {
    my $self = shift;
    my ($host, $port, $path, $timeout, $mode) = @_;
    my ($addr, $name, $aliases, $addrtype, $length, $here, $there);
    my ($respcode, $respmesg, $headers, $query);
    local($/);

    $socket = $magic++;
    $timeout ||= 120;
    $mode ||= "HTTP/1.0";
    $mode = "" if $mode eq '*';

    ## Get a socket and bind it.
    socket($socket, &AF_INET, &SOCK_STREAM, 0)
	|| throw($socket, "ERROR 1004: Couldn't get socket: $!");

    $self->{'socket'} = $socket;

    $here = pack('S n a4 x8', &AF_INET, 0, pack('c4', 0, 0, 0, 0));
    bind($socket, $here)
	|| throw($socket, "ERROR 1004: Can't bind socket: $!");

    $addr = EWShttp::addrByName_impl($host);
    die "ERROR 1002: Couldn't get address for '$host'" if (!$addr);

    $there = pack('S n a4 x8', &AF_INET, $port, $addr);

    $SIG{'ALRM'} = 'EWShttp::timeout';
    alarm($timeout);

    connect($socket, $there)
	|| throw($socket, "ERROR 1003: Can't connect: $!");

    alarm($timeout);
    select((select($socket), $|=1)[0]);

    ## send QUERY line
    $query = "GET $path $mode";
    $query =~ s/\s+$//;
    print {$socket} "$query\r\n";

    ## send additional REQUEST HEADERS
    for (keys %{$self->{'OutHdr'}}) {
	if ($ {$self->{'OutHdr'}}{$_} ne "") {
	    print {$socket} "$_: ", $self->{'OutHdr'}{$_}, "\r\n";
	}
    }


    ##### HOST HOST HOST HOST HOST
    ## logMsg("DEBUG: host == $host");
    if ($host =~ /204\.62\.129\.(\d+)/) {
	if ($1 == 133 || $1 == 5) {
	    print {$socket} "Host: www.netizen.com\n";
	}
	if ($1 == 129 || $1 == 1) {
	    print {$socket} "Host: www.hotwired.com\n";
	}
    }

    print {$socket} "\r\n";
    alarm($timeout);

    ## RESPONSE MESSAGE.
    ## READ FROM THE SOCKET.
    if ($mode) {    ## e.g., "HTTP/1.0"
	$/ = "\n";
	$_ = <$socket>;

	## CHECK FOR STATUS MSG.
	## IF THERE IS ONE, GRAB THE CODE.
	die "ERROR 1001: Bad HTTP response ($_)" 
	    unless  m|^HTTP\S*\s+(\d+)\s+(.*)$|;
	($respcode, $respmesg) = ($1, $2);

	## GRAB THE RESPONSE HEADERS, THEN PARSE THEM.
	while (<$socket>) {
	    alarm($timeout);
	    last if /^[\r\n]+$/;
	    $headers .= $_;
	}
	$self->parse_headers($headers);

	if ($respcode != 200) {
	    throw($socket, "HTTP ERROR: $respcode $respmesg\n");
	}
    }
    return "";
}

########################################################################

sub close {
    my $self = shift;
    my($sc) = $self->{'socket'};
    close $sc if ($sc);
    $self->{'socket'} = "";
}

sub filenum {
    my $self = shift;
    my($sc) = $self->{'socket'};
    return fileno($sc);
}

sub get {
    my $self = shift;
    my ($len) = shift;
    my ($ret);
    $ret = eval { $self->get_impl($len) };
    alarm(0);
    $SIG{'ALRM'} = 'IGNORE';
    $ret = -1 if $@;
    return ($ret, "$@ Read Failed.");
}

sub get_impl {
    my $self = shift;
    my ($size) = shift;
    my ($retlen, $val);
  
    my ($sc) = $self->{'socket'};

    $SIG{'ALRM'} = 'EWShttp::timeout';
    alarm(120);

    $retlen = read($sc, $val, $size);
    $self->{'body'} = $val;
    if (!(defined($retlen))) {
	## close ($sc);
	## $self->{'socket'} = "";
	$retlen = -1;
	die "ERROR 1005: Socket Read Failed: $!";
    }
    return $retlen;
}

########################################################################

sub body {
    my $self = shift;
    return $self->{'body'};
}

sub response_headers {
    my $self = shift;
    return %{$self->{'InHdr'}};
}

########################################################################

sub printHeaders {
    my $self = shift();
    for (keys %{$self->{'OutHdr'}}) {
	print "$_: $ {$self->{'OutHdr'}}{$_}\n";
    }
}


sub header_agent {
    my $self = shift();
    my $user_agent = shift();
    $self->{'OutHdr'}{'User-agent'} = $user_agent;
    $self;
}

sub header_from {
    my $self = shift();
    my $from = shift();
    $self->{'OutHdr'}{'From'} = $from;
    $self;
}

sub header_authorization {
    my $self = shift();
    my $auth = shift();
    $self->{'OutHdr'}{'Authorization'} = $auth;
    $self;
}

########################################################################

sub ipAddrByName {
    my($host) = shift;
    my($ipaddr) = addrByName($host);
    ($ipaddr) && ($ipaddr = join(".", unpack("C4", $ipaddr)));
    return $ipaddr;
}

sub addrByName {
    local($host) = shift;
    local ($ret);
    $ret = eval { EWShttp::addrByName_impl($host) };
    alarm(0);
    $SIG{'ALRM'} = 'IGNORE';
    return "" if $@;
    return $ret;
}

sub addrByName_impl {
    local($host) = shift;
    local($name, $aliases, $addrtype, $length, $addr);

    $SIG{'ALRM'} = 'EWShttp::timeout';
    alarm($timeout);

    if ($host =~ /^\d+\.\d+\.\d+\.\d+$/) {
	$addr = pack('c4', split(/\./, $host));
    } else {
	$addr = $addr_cache{$host};
	if (!$addr) {

	    ## try to get the address 3 times.  if fail, then return failure.
	    my $retryTimes=3;
	    my $times=0;
	    while (!$addr) {
		($name, $aliases, $addrtype, $length, $addr) 
		    = gethostbyname($host);
		$times++;
		last if $addr;
		last if ($times==$retryTimes);
	    }
	    
	    return $addr if (!$addr);
	    if ($#addr_cache > $IPCACHE) {
		$del_host = shift(@addr_cache);
		delete $addr_cache{$del_host};
	    }
	    push(@addr_cache, $host);
	    $addr_cache{$host} = $addr;
	}
    }
    return $addr;
}

########################################################################

sub throw {
    local ($h, $mesg) = @_;
    close($h) if $h;
    die $mesg;
}

sub timeout {
    ## print "ERROR 1000: Timed out\n";
    ## close($socket) if $socket;
    die "ERROR 1000: Timed out";
}

sub parse_headers {
    my ($self) = shift;
    local($_) = shift;
    my ($headers) = {};
    my ($keyw, $val, @array);
    local($*) = 1;

    s/\r//g;
    s/\n\s+/ /g;

    @array = split('\n');
    foreach $_ (@array)
    {
        ($keyw, $val) = m/^([^:]+):\s*(.*\S)\s*$/g;
        $keyw =~ tr/A-Z/a-z/;
        if (defined($headers->{$keyw})) {
            $headers->{$keyw} .= ", $val";
        } else {
            $headers->{$keyw} = $val;
        }
	## print "$keyw:$val\n";
    }

    $self->{'InHdr'} = $headers;
}


1;

