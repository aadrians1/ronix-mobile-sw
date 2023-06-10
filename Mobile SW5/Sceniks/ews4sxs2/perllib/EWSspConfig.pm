
require 5.000;
package EWSspConfig;

## GET DIR IN WHICH TO RUN THE SPIDER ($spider_home_dir)
$ahome = '/tmp';
$ahome = $ENV{'ARCHITEXT_HOME'} if ($ENV{'ARCHITEXT_HOME'});
## $spider_home_dir = "$ahome/EWSspider";
$spider_home_dir = ".";
$spider_home_dir = $ENV{'SPIDER_HOME'} if ($ENV{'SPIDER_HOME'});

## SET DEFAULT VALUES FOR CONFIG ITEMS
$addr_db_infile = "$spider_home_dir/addr_db.txt";
$addr_db_outfile = "$spider_home_dir/addr_db.txt.post";
$user_agent = undef;
$from_agent = undef;
$polite_time = 60;
$doneFile = "$spider_home_dir/done";
$initialUrlListFile = "$spider_home_dir/initialUrls.cfg";
$domainListFile = "$spider_home_dir/domainList.cfg";
$fetchUrlFilterFile = "$spider_home_dir/fetchUrlFilter.cfg";
$dumpUrlFilterFile = "$spider_home_dir/dumpUrlFilter.cfg";
$retryLogicFile = "$spider_home_dir/retryLogic.cfg";
$saveFile = "$spider_home_dir/state";
$overflowFile = "$spider_home_dir/overflow";
{ 
    my ($s, $min, $hr, $d, $m, $y, $misc) = localtime(time);
    $m++;
    $logFile = "$spider_home_dir/log";
}
$dumpDir = "$spider_home_dir/dumps";

$ignore_robot_error = 0;
$maxDumpsPerSite = 500;
$docsPerDump = 1;
$dumpSuffix = 'html';
$docSeparator = "NewURL" . ("-" x 70) . "\n";



@ignore_content_type = ();
@ignore_suffix = ();
@ignore_path_pattern = ();

$ignore_suffix_expr = "";
$ignore_content_type_expr = "";
$ignore_path_pattern_expr = "";

## 0 : Needs to be defined by user.
%config_vars = 
    (
     'user_agent', 0,
     'from_agent', 0,
     'polite_time', 1,
     'initialUrlListFile', 1,
     'domainListFile', 1,
     'fetchUrlFilterFile', 1,
     'dumpUrlFilterFile', 1,
     'retryLogicFile', 1,
     'logFile', 1,
     'dumpDir', 1,
     'ignore_robot_error', 1,
     'maxDumpsPerSite', 1,
     'docsPerDump', 1,
     'dumpSuffix', 1,
     'docSeparator', 1
     );

%config_avars = 
    (
     'ignore_content_type', 1, 
     'ignore_suffix', 1 ,
     'ignore_path_pattern', 1 
     );

{
    my $configFile = "$spider_home_dir/config";
    open(CFILE, $configFile) || die "Cannot open Config file $configFile: $!";

    my ($field);
    my ($value);

    while (<CFILE>) {
	next if /^\s*\#/;
	s/\#.*$//;              # comments
	s/^\s+//;               # leading space
	s/\s+$//;               # trailing space
	next if ($_ eq '');
	if (!/:/) {
	    warn "$configFile, line $.: Invalid line '$_'\n";
	    next;
	}
	($field, $value) = split(/\s*:\s*/, $_, 2);
	if (defined $config_vars{$field}) {
	    $$field = $value;
	    $config_vars{$field} = 1;
	    next;
	}
	if (defined $config_avars{$field}) {
	    push (@{$field}, $value);
	    $config_avars{$field} = 1;
	    next;
	}
	warn "$configFile, line $.: Invalid option '$field'\n";
    }
    close(CFILE);
    
    my($f);
    foreach $f (@ignore_suffix) {
	$ignore_suffix_expr .= "|" if ($ignore_suffix_expr); 
	$ignore_suffix_expr .= "$f";
    }
    foreach $f (@ignore_content_type) {
	$ignore_content_type_expr .= "|" if ($ignore_content_type_expr); 
	$ignore_content_type_expr .= "$f";
    }
    foreach $f (@ignore_path_pattern) {
	$ignore_path_pattern_expr .= "|" if ($ignore_path_pattern_expr); 
	## $ignore_path_pattern_expr .= "$f";
	$f =~ (s/,/\\,/) ;
	eval "m,$f,";
	if ($@) {
	    print STDERR "Error in ignore_path_pattern: $f: $@\n";
	    return 0;
	}
	$ignore_path_pattern_expr .= "$f";
    }
}

die "Cannot proceed until required options are set" 
    unless verifyConfig();

(-e $dumpDir) || (mkdir($dumpDir, 0777)) || die "Cannot create $dumpDir: $!";

########################################################################
########################################################################

sub debugPrint {
    my $f;
    foreach $f (keys %config_vars) {
	print "$f : $$f\n";
    }
    foreach $f (keys %config_avars) {
	print "$f : @$f\n";
    }
    1;
}

sub verifyConfig {
    my $ok = 1;
    my $k;
    foreach $k (keys %config_vars) {
	$ok = 0, print("Required option Not set: $k\n") 
	    unless $config_vars{$k};
    }
    foreach $k (keys %config_avars) {
	$ok = 0, print("Required option Not set: $k\n") 
	    unless $config_avars{$k};
    }
    return $ok;
}

sub ignoredUrlSuffix {
    my($path) = shift;
    return 0 unless $ignore_suffix_expr;
    return ($path =~ m/\.($ignore_suffix_expr)$/oix);
}

sub ignoredPath {
    my($path) = shift;
    return 0 unless $ignore_path_pattern_expr;
    return ($path =~ m,$ignore_path_pattern_expr,i);
}

sub ignoredUrlSuffixExpr {
    return $ignore_suffix_expr;
}

sub ignoredContentTypeExpr {
    return $ignore_content_type_expr;
}

1;

