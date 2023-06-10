#!/bin/sh
perl=/usr/local/bin/perl5
eval "exec $perl -x $0 $*"
#!perl
## Copyright (c) 1996 Excite, Inc.
##
## This CGI script allows users to configure Excite, Inc. databases
## through a WWW interface. Naturally, there are plenty of security
## concerns associated with this scheme.
##
## This script appears as several different web pages, depending on
## its invocation. If invoked with a 'db=<database>' argument, the
## script prints out the configuration information for a particular
## database and then allows the user to change it. If invoked with
## 'new=<database>', the user is allowed to create a new database. If
## invoked with 'Update=Update' and 'dbname=<database>', it updates an
## existing database configuration file. Without any of these
## arguments, it displays a list of currently existing database.conf
## files, and also allows the user to create a new database.conf file.

## terminologies:
##    global - values in file "global"
##    main   - values in file "$collection.sd/main"
##    site   - values in file "$collection.sd/site.#####"

#########################################
##
## TODO: deleting collections
##       starting/stopping spider (currently, the script waits until
##       spider is done.
##       rename collection
##       info on top of main.html
##       better error checking
##
#########################################

BEGIN {
  $root = "/home/jimh/src/prog/EWS2.0";
  $spider_dir="/home/jimh/spider3";
  $perlportname = "sun4-solaris";
  die "Invalid root directory '$root'\n" unless -d $root;
  unshift(@INC, "$root/perllib", "$root/perllib/$perlportname/5.002",
	  "$root/perllib/$perlportname");
}

require 'os_functions.pl';
require 'architext.pl';
require 'architextConf.pl';
require 'architext_map.pl';

%form = &Architext'readFormArgs;
%attr = &ArchitextConf'readConfig("$root/Architext.conf", $form{'db'});

if (&Architext'remoteMode($root)) {
    $helppath = &Architext'helpPath();
} else {
    $helppath = $attr{'ArchitextURL'};
}

$script_suffix = &Architext'scriptSuffix();
$script_name = "AT-spider$script_suffix";

## check for password, if one is specified in Architext.conf
## if it doesn't appear as a form arg, present password page
$password = &Architext'password($attr{'ArchitextURL'},
				$scriptname,
				$attr{'Password'}, 
				%form) if $attr{'Password'};

$postpass = 
    "<INPUT TYPE=\"hidden\" NAME=\"$password\" VALUE=\"$attr{'Password'}\">" if
    ($attr{'Password'});
$getpass = "?$password=$attr{'Password'}" if $postpass;

$spider_config = "$root/spider";

$action = $form{'action'};
$action = 'list' unless $action;

## from list.html
$collection = $form{'collection'};

## from main.html
$user_agent = $form{'user_agent'};
$from_agent = $form{'from_agent'};
$polite_time = $form{'polite_time'};
$use_as_global = $form{'use_as_global'};
$MAX_SIZE = $form{'MAX_SIZE'};
$MAX_PAGES = $form{'MAX_PAGES'};
$AVOID_SUFFIX = $form{'AVOID_SUFFIX'};
$AVOID_STRING = $form{'AVOID_STRING'};
$ews_site = $form{'ews_site'};

##values in collection's configuration files...
@global_config_keys = ('user_agent',
		       'from_agent',
		       'polite_time');

@main_config_keys = ('MAX_SIZE',
		     'MAX_PAGES',
		     'user_agent',
		     'from_agent',
		     'polite_time',
		     'AVOID_SUFFIX',
		     'AVOID_STRING');

@site_config_keys = ('DOMAIN_NAME',
		     'MAX_SIZE',
		     'MAX_PAGES',
		     'AVOID_SUFFIX',
		     'AVOID_STRING',
		     'STARTING_POINTS');

$PAGES{'list'} = "AT-spider_list.html";
$PAGES{'Configure Collection'} = "AT-spider_main.html";
$PAGES{'Delete Collection'} = "AT-spider_general.html";
$PAGES{'New Collection'} = "AT-spider_new.html";
$PAGES{'Configure Site'} = "AT-spider_site.html";
$PAGES{'Save Site Info'} = "AT-spider_general.html";
$PAGES{'Cancel Changes'} = "AT-spider_general.html";
$PAGES{'Update Spider Configuration'} = "AT-spider_general.html";
$PAGES{'Delete Site'} = "AT-spider_general.html";
$PAGES{'Start Spider'} = "AT-spider_general.html";
$PAGES{'Stop Spider'} = "AT-spider_general.html";

$sban = &Architext'spiderBanner();
$SUBS{'EWS_SPIDER_BANNER'} = "$attr{'ArchitextURL'}pictures/$sban";
$SUBS{'EWS_PASSWORD'} = $postpass;
$SUBS{'EWS_ADMIN_CGI'} = "AT-admin$script_suffix";
$SUBS{'EWS_SPIDER_CGI'} = $script_name;
$SUBS{'EWS_COLLECTION'} = $collection if $collection;
$SUBS{'EWS_ACTION'} = $action;
$SUBS{'EWS_URL'} = $attr{'ArchitextURL'};

## this is the first page the user encounters
if ($action eq 'list') {
    $collection_list = &htmlOptionList(&collectionList($spider_config));
    $SUBS{'EWS_COLLECTION_LIST'} = $collection_list;
    $SUBS{'EWS_COLLECTION'} = 'collection';
    $SUBS{'EWS_TITLE'} = "Excite for Web Servers Spider Collections";
    $SUBS{'EWS_TEMPLATE'} = $PAGES{$action};
    showPage(%SUBS);
}

## after use hits "Configure Collection" on the first ('list') page
if ($action eq 'Configure Collection') {
## first read global values
    %spider_config_global = readGlobalConfig("$spider_config");
    $SUBS{'EWS_USER_AGENT'} = $spider_config_global{'user_agent'};
    $SUBS{'EWS_FROM_AGENT'} = $spider_config_global{'from_agent'};
    $SUBS{'EWS_POLITE_TIME'} = $spider_config_global{'polite_time'};

## next read main values and display main if exist
## TODO: ensure that a collection was selected when 'Configure Collection' is
##       pushed. otherwise a collection by the name of ".sd" will
##       be created.
    if (! -d "$spider_config/$collection".".sd") {
	mkdir("$spider_config/$collection".".sd", 0777);
	chmod(0777, "$spider_config/$collection".".sd");  ## hack for now
    } else {
	%spider_config_main = readMainConfig("$spider_config/$collection");
    }
    $SUBS{'EWS_USER_AGENT'} = $spider_config_main{'user_agent'} if
	$spider_config_main{'user_agent'};
    $SUBS{'EWS_FROM_AGENT'} = $spider_config_main{'from_agent'} if
	$spider_config_main{'from_agent'};
    $SUBS{'EWS_POLITE_TIME'} = $spider_config_main{'polite_time'} if
	$spider_config_main{'polite_time'} =~ /\w/;

## then display other info from 'main'
    $SUBS{'EWS_MAX_SIZE'} = $spider_config_main{'MAX_SIZE'};
    $SUBS{'EWS_MAX_PAGES'} = $spider_config_main{'MAX_PAGES'};
    $SUBS{'EWS_AVOID_SUFFIX'} = $spider_config_main{'AVOID_SUFFIX'};
    $SUBS{'EWS_AVOID_STRING'} = $spider_config_main{'AVOID_STRING'};

## display sites
    $SUBS{'EWS_SITE_LIST'} = "";    ## in case nothing
    %spider_site_names = readSiteNames("$spider_config/$collection");
    while (($site, $domain) = each (%spider_site_names)) {
	$SUBS{'EWS_SITE_LIST'} .= "<OPTION VALUE=\"$site\"> $domain\n";
    }

    $SUBS{'EWS_TEMPLATE'} = $PAGES{$action};
    showPage(%SUBS);
}

## from 'list' page, hit 'Update Spider Configuraiton'

## TODO: allow user to update global values w/o updating local ones?
## currently, updates are performed to both or local only.

if ($action eq 'Update Spider Configuration') {
    $error = writeMainConfig("$spider_config/$collection");
    if (!$error && $use_as_global) {
	writeGlobalConfig("$spider_config");
    }

    $SUBS{'EWS_TEMPLATE'} = $PAGES{$action};
    $SUBS{'EWS_VERB'} = "Update";
    $SUBS{'EWS_OBJECT'} = "Main Spider Configuration";
    $SUBS{'EWS_GERUND'} = "Updating";

    ## determine success or failure here, set SUBS below accordingly
    $SUBS{'EWS_SUCCESS'} = ($error ? "NOT " : "")."successful";
    $SUBS{'EWS_ERROR_MESSAGE'} = "$error";
    showPage(%SUBS);
}

## from 'main' page, hit 'Configure Site'
if ($action eq 'Configure Site') {
    if ($ews_site eq "New Site") {
	$ews_site = getNewSiteName("$spider_config/$collection");

    }

    $SUBS{'EWS_TITLE'} = 
	"Edit Excite for Web Servers Spider Site: $ews_site";
    $SUBS{'EWS_TEMPLATE'} = $PAGES{$action};

    $SUBS{'EWS_SITE'} = $ews_site;
    %spider_config_site = &readSiteConfig("$spider_config/$collection",
					  $ews_site);

    $SUBS{'EWS_DOMAIN_NAME'} = $spider_config_site{'DOMAIN_NAME'};
    $SUBS{'EWS_MAX_PAGES'} = $spider_config_site{'MAX_PAGES'};
    $SUBS{'EWS_STARTING_POINTS'} = $spider_config_site{'STARTING_POINTS'};
    $SUBS{'EWS_AVOID_SUFFIX'} = $spider_config_site{'AVOID_SUFFIX'};
    $SUBS{'EWS_AVOID_STRING'} = $spider_config_site{'AVOID_STRING'};

    showPage(%SUBS);
}

## from 'site' page, hit 'Save Site Info'
if ($action eq 'Save Site Info') {
    $SUBS{'EWS_TEMPLATE'} = $PAGES{$action};

    $SUBS{'EWS_VERB'} = "Update";
    $SUBS{'EWS_OBJECT'} = "Spider Site Configuration";
    $SUBS{'EWS_GERUND'} = "Updating";

    $error = writeSiteConfig("$spider_config/$collection", $ews_site);
    ## determine success or failure here, set SUBS below accordingly
    $SUBS{'EWS_SUCCESS'} = ($error ? "NOT " : "")."successful";
    $SUBS{'EWS_ERROR_MESSAGE'} = "$error";
    
    showPage(%SUBS);
}

## from 'site' page, hit 'Cancel Changes'
if ($action eq 'Cancel Changes') {
    $SUBS{'EWS_TEMPLATE'} = $PAGES{$action};

    $SUBS{'EWS_VERB'} = "Cancel";
    $SUBS{'EWS_OBJECT'} = "Spider Site Configuration";
    $SUBS{'EWS_GERUND'} = "Updating";

    $SUBS{'EWS_SUCCESS'} = "cancelled";
    $SUBS{'EWS_ERROR_MESSAGE'} = "";
    
    showPage(%SUBS);
}

## from 'list' page, hit 'New Collection'
if ($action eq 'New Collection') {
    $SUBS{'EWS_TEMPLATE'} = $PAGES{$action};

    showPage(%SUBS);
}

## from 'list' page, hit 'Delete Collection'
if ($action eq 'Delete Collection') {

#### TODO: iterately/recursively remove all config files in the collection 

    $SUBS{'EWS_SUCCESS'} = ($error ? "NOT " : "")."successful";
    $SUBS{'EWS_ERROR_MESSAGE'} = "Actually, this doesn't work yet.";
    $SUBS{'EWS_TEMPLATE'} = $PAGES{$action};

    showPage(%SUBS);
}

if ($action eq 'Delete Site') {
    $error = unlink("$spider_config/$collection.sd/$ews_site");

    $SUBS{'EWS_VERB'} = "Delete";
    $SUBS{'EWS_OBJECT'} = "Spider Site Configuration file: $ews_site";
    $SUBS{'EWS_GERUND'} = "Deleting";

    $SUBS{'EWS_SUCCESS'} = ($error eq 0 ? "NOT " : "")."successful";
    $SUBS{'EWS_ERROR_MESSAGE'} = "";
    $SUBS{'EWS_TEMPLATE'} = $PAGES{$action};

    showPage(%SUBS);
}

if ($action eq 'Start Spider') {
## convert config files
    @systemlist=("./convert.pl", $spider_config, $collection, $spider_dir);
    system(@systemlist);
    $error = $?>>8;

## run spider
    if (! $error) {
	chdir($spider_dir);
	@systemlist=("./collector.pl");
	system(@systemlist);
	$error = $?>>8;
	chdir($root);
    }

    $SUBS{'EWS_VERB'} = "Run";
    $SUBS{'EWS_OBJECT'} = "Spider";
    $SUBS{'EWS_GERUND'} = "Running";

    $SUBS{'EWS_SUCCESS'} = ($error eq 0 ? "" : "NOT ")."successful";
    $SUBS{'EWS_ERROR_MESSAGE'} = "$error";

    $SUBS{'EWS_TEMPLATE'} = $PAGES{$action};
    showPage(%SUBS);
}

if ($action eq 'Stop Spider') {
    showPage(%SUBS);
}


exit(0);

## searches collection for lowest unused site name
sub getNewSiteName {
    local($file) = @_;
    $file .= ".sd";
    local($i) = 1;
    local($name);

    while ($i < 100000) {
	$name = sprintf("$file/site.%05d", $i);
	last if (! -e $name);
	$i++;
    }
    $name =~ /$file\//;
    $name = $';
    $name;
}

## takes an associative array and writes the site config file
## to disk...
sub writeSiteConfig {
    local($file, $site) = @_;
    $file .= ".sd/$site";
    open(CFILE, ">$file") ||
	($error_value = "Couldn't open '$file' for writing.");
    for (@site_config_keys) {
	if ($form{$_} =~ /\w/) {
	    if ($_ eq "AVOID_SUFFIX") {
		foreach $value (split(/ /, $form{$_})) {
		    print CFILE "$_ $value\n";
		}
	    } elsif ($_ eq "AVOID_STRING") {
		foreach $value (split(/\n/, $form{$_})) {
		    print CFILE "$_ $value\n" if $value =~ /\w/;
		}
	    } elsif ($_ eq "STARTING_POINTS") {
		print CFILE "$_\n";
		foreach $value (split(/\n/, $form{$_})) {
		    print CFILE "$value\n" if $value =~ /\w/;
		}
	    } else {
		print CFILE "$_ $form{$_}\n";
	    }
	}
    }
    close(CFILE); 
    $error_value;
}

## reads a site config file and returns the contents
## in associative array
sub readSiteConfig {
    local($file, $site) = @_;
    local(%spider_collection_site);
    local($value);
    $file .= ".sd/$site";

    if (! open(CFILE, "$file")) {
	$error_value = "Couldn't open '$file' for reading.";
    } else {
	while (<CFILE>) {
	    foreach $key (@site_config_keys) {
		if ($_ =~ /^$key/) {
		    $value = $';
		    $value =~ s/ //;
		    $value =~ s/\n//;
		    if ($key eq "AVOID_SUFFIX") {
			$spider_collection_site{$key} .= $value." ";
		    } elsif ($key eq "AVOID_STRING") {
			$spider_collection_site{$key} .= $value."\n";
		    } elsif ($key eq "STARTING_POINTS") {
			while (<CFILE>) {
			    s/ //;
			    s/\n//;
			    if (/\w/) {
				$spider_collection_site{$key} .= $_."\n";
			    }
			}
		    } else {
			$spider_collection_site{$key} = $value;
		    }
		}
	    }
	}
	chop($spider_collection_site{'AVOID_SUFFIX'});
	chop($spider_collection_site{'AVOID_STRING'});
    }
    close(CFILE);
    %spider_collection_site;
}

## reads the names of the sites for the given collection and return the info
## in associative array
sub readSiteNames {
    local($dir) = @_;
    local(%spider_collection_site_names);
    local($value);
    local($site);
    $dir .= ".sd";

    while ($site = <$dir/site.*>) {
	if ($site =~ /site.\d\d\d\d\d$/) {
	    if (! open(CFILE, "$site")) {
		$error_value = "Couldn't open '$site' for reading.";
	    } else {
		$site = $&;      ## matched portion only
		while (<CFILE>) {
		    if ($_ =~ /^DOMAIN_NAME/) {
			$value = $';
			$value =~ s/ //;
			$value =~ s/\n//;
			$spider_collection_site_names{$site} = $value;
			last;
		    }
		}
	    }
	}
    }

    close(CFILE);
    %spider_collection_site_names;
}

## takes an associative array and writes the global config file
## to disk...
sub writeGlobalConfig {
    local($file) = @_;
    $file .= "/global";
    open(CFILE, ">$file") ||
	($error_value = "Couldn't open '$file' for writing.");
    for (@global_config_keys) {
	print CFILE "$_ $form{$_}\n" if $form{$_} =~ /\w/;
    }
    close(CFILE); 
    $error_value;
}

## reads the global config file and returns the contents
## in associative array
sub readGlobalConfig {
    local($file) = @_;
    local(%spider_collection_global);
    local($value);
    $file .= "/global";
    if (! open(CFILE, "$file")) {
	$error_value = "Couldn't open '$file' for reading.";
    } else {
	while (<CFILE>) {
	    foreach $key (@global_config_keys) {
		if ($_ =~ /^$key/) {
		    $value = $';
		    $value =~ s/ //;
		    $value =~ s/\n//;
		    $spider_collection_global{$key} = $value;
		}
	    }
	}
    }
    close(CFILE);
    %spider_collection_global;
}

## takes an associative array and writes the main config file
## to disk...
sub writeMainConfig {
    local($file) = @_;
    $file .= ".sd/main";
    open(CFILE, ">$file") ||
	($error_value = "Couldn't open '$file' for writing.");
    for (@main_config_keys) {
	if ($form{$_} =~ /\w/) {
	    if ($_ eq "AVOID_SUFFIX") {
		foreach $value (split(/ /, $form{$_})) {
		    print CFILE "$_ $value\n";
		}
	    } elsif ($_ eq "AVOID_STRING") {
		foreach $value (split(/\n/, $form{$_})) {
		    print CFILE "$_ $value\n" if $value =~ /\w/;
		}
	    } else {
		print CFILE "$_ $form{$_}\n";
	    }
	}
    }
    close(CFILE); 
    $error_value;
}

## reads a main config file and returns the contents
## in associative array
sub readMainConfig {
    local($file) = @_;
    local(%spider_collection_main);
    local($value);
    $file .= ".sd/main";
    if (! open(CFILE, "$file")) {
	$error_value = "Couldn't open '$file' for reading.";
    } else {
	while (<CFILE>) {
	    foreach $key (@main_config_keys) {
		if ($_ =~ /^$key/) {
		    $value = $';
		    $value =~ s/ //;
		    $value =~ s/\n//;
		    if ($key eq "AVOID_SUFFIX") {
			$spider_collection_main{$key} .= $value." ";
		    } elsif ($key eq "AVOID_STRING") {
			$spider_collection_main{$key} .= $value."\n";
		    } else {
			$spider_collection_main{$key} = $value;
		    }
		}
	    }
	}
	chop($spider_collection_main{'AVOID_SUFFIX'});
	chop($spider_collection_main{'AVOID_STRING'});
    }
    close(CFILE);
    %spider_collection_main;
}

sub htmlOptionList {
    local(@olist) = @_;
    local($html_string);
    for (@olist) {
	$html_string = "$html_string <OPTION>$_";
    }
    $html_string;
}

sub collectionList {
    local($dir) = @_;
    local(@spiders);
    opendir(SDIR, $dir);
    @spiders = grep(/\.sd$/, readdir(SDIR));
    closedir(SDIR);
    for (@spiders) { s/\.sd$//; }
    @spiders;
}

sub showPage {
    local(%SUBS) = @_;
    local($template) = $SUBS{'EWS_TEMPLATE'};
    &Architext'printHttpHeader();
    ## don't do anything, just report action if no template file given
    if (! $template) {
	print <<EOF;
<html><head><title> EWS Spider Administration </title></head>
<body><h1>Action: $SUBS{'EWS_ACTION'}</h1>

EOF
;
    goto FOOTER;
    }
    open(TFILE, $template);
    while (<TFILE>) {
	while (($key, $value) = each %SUBS) {
	    s/$key/$value/g;
        }
	print $_;
    }
    close(TFILE);
FOOTER:
    &Architext'Copyright($attr{'ArchitextURL'});
    print "</BODY></HTML>";
}
