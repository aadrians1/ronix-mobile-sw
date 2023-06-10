#!/bin/sh
perl=/usr/local/www/scenix.com/ews4sxs2/perl
eval "exec $perl -x $0 $*"
#!perl

## Copyright (c) 1996 Excite, Inc.
##
## This CGI script allows users to index Excite, Inc. databases
## through a WWW interface. Naturally, there are plenty of security
## concerns associated with this scheme.
##
## This script appears as several different web pages, depending on
## its invocation. If invoked with a 'db=<database>' argument, the
## script prints out the configuration information for a particular
## database and then allows the user to change it. If
## invoked with 'Index=Index' and 'dbname=<database>', it will ininitialize 
## a database which has an existing database configuration file. 
## Without any of these arguments, it displays a list of currently 
## existing database.conf files, and allows the user to choose a database 
## to index.

BEGIN {
  $root = "/usr/local/www/scenix.com/ews4sxs2";
  die "Invalid root directory '$root'\n" unless -d $root;
  unshift(@INC, "$root/perllib");
}

$| = 1;  ## don't buffer output

require 'os_functions.pl';
require 'architext.pl';
require 'architextConf.pl';

%form = &Architext'readFormArgs;
%attr = &ArchitextConf'readConfig("$root/Architext.conf", $form{'db'});

if (&Architext'remoteMode($root)) {
    $helppath = &Architext'helpPath();
} else {
    $helppath = $attr{'ArchitextURL'};
}

$script_suffix = &Architext'scriptSuffix();
$scriptname = "AT-index$script_suffix";

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

if ($form{'Stop'}) {
   &Architext'printHeader($attr{'ArchitextURL'},
			   "Stop Indexing: $form{'db'}");
   $pidfile = "$root/collections/$form{'db'}.pid";
   if (! -e $pidfile) {
       &Architext'exitError($attr{'ArchitextURL'}, 
			    "<b>You tried to stop an indexing process that wasn't running</b>");
   }
   open(PID, "$pidfile");
   while (<PID>) {
       $pid = $_;
   }
   close(PID);
   &kill_process($pid, $root);
   &remove_files($pidfile);	
   open(TERM, ">$root/collections/$form{'db'}.term");
   close(TERM);
   print "<p> <b>Indexing process number $pid has been terminated.</b>\n";
   print <<EOF;
<p> 
<FORM ACTION="AT-admin$script_suffix" METHOD=POST>
<INPUT TYPE="hidden" NAME="db" VALUE="$form{'db'}">
<INPUT TYPE="submit" NAME="Admin" VALUE="Admin">
Go back to the admin page for this collection.
$postpass
</FORM><BR>
EOF
    ;
   &Architext'Copyright($attr{'ArchitextURL'});
   exit(0);
}

if ($form{'db'}) {
    ## Print out configuration options for an already-existing
    ## database so the user knows what will happen upon indexing

    ## Dump our standard header
    &Architext'printHeader($attr{'ArchitextURL'},
			   "Collection Indexing: $form{'db'}");

    ## Check for the desired database.conf file.
    $dbconfig = $root . "/collections/" . $form{'db'} . ".conf";
    if (! -r $dbconfig) { 
	&Architext'exitFileError($attr{'ArchitextURL'},
				 $dbconfig, "does not exist"); }

    ## Read all the configuration information.
    ##%attr = &ArchitextConf'readConfig("$root/Architext.conf", $form{'db'});

    print "<p> The collection you have chosen has the ";
    print "following characteristics:\n";
    ## Print the form.
    &Architext'collectionCharacteristics($form{'db'}, $helppath, %attr); 
    ## This form is just a little list of the options.
    &printForm($form{'db'});    
    &Architext'Copyright($attr{'ArchitextURL'});

}  elsif ($form{'Index'}) {
    ## Assuming all the relevant configuration options are specified
    ## as form arguments, this mode actually starts the indexing .

    ## Header again
    &Architext'printHeader($attr{'ArchitextURL'},
			   "Collection Indexing: $form{'dbname'}");

    if (!$form{'dbname'}) { 
	&Architext'exitError($attr{'ArchitextURL'},
			     "Index specified with no dbname."); }

    ## Can we read the db.conf file?
    $dbconfig = $root . "/collections/" . $form{'dbname'} . ".conf";
    if (! -e $dbconfig && ! -r $dbconfig) {
	&Architext'exitFileError($attr{'ArchitextURL'},
				 $dbconfig, 
				 "does not exist or is not readable.");
    }

    if (-e "$root/collections/$form{'dbname'}.pid") {
	print <<EOF;
<p><b>An indexing process is already in progress for this collection.</b>
<FORM ACTION="AT-index$script_suffix" METHOD=POST>
<INPUT TYPE="submit" NAME="Stop" VALUE="Stop Indexing">
Stop the indexing process that is currently running on this collection.
<INPUT TYPE="hidden" NAME="db" VALUE="$form{'dbname'}">
$postpass
</FORM><BR>
EOF
    ;
	&Architext'Copyright($attr{'ArchitextURL'});
	exit(0);
    }

    ## tell the user it started the process.
    ## variables below tell user how to access log file and prog
    ## progress file from browser, and tell indexer exactly where
    ## to put them.
    $logname = "AT-$form{'dbname'}.log";
    $progname = "AT-$form{'dbname'}.prog";
    $errname = "AT-$form{'dbname'}.err";
    $realpath = "$root/collections";
    $urlpath = $attr{'ArchitextURL'};
    print "<H2>Indexing initiated.</H2>\n";
    print "<p><hr>\n";
    if ($getpass) {
	$getpass .= "&";
    } else {
	$getpass = "?";
    }
    $getpass .= "db=$form{'dbname'}";
    if ($ews_port eq 'NT') {
	$contact_phrase = "to contact you via the NT messenger service";
    } else {
	$contact_phrase = "to send email";
    }
    print <<EOF;
<b>Possible Actions:</b>
<p>While you are waiting for the indexing process to complete, you can: 
<p> <FORM ACTION="AT-generate$script_suffix" METHOD=POST>
<INPUT TYPE="submit" NAME="Status" VALUE="View Logs">
View the log files created by the indexing process.  
<INPUT TYPE="hidden" NAME="db" VALUE="$form{'dbname'}">
$postpass
</FORM>
<p>
<FORM ACTION="AT-index$script_suffix" METHOD=POST>
<INPUT TYPE="submit" NAME="Stop" VALUE="Stop Indexing">
Stop the indexing process that was just initiated.
<INPUT TYPE="hidden" NAME="db" VALUE="$form{'dbname'}">
$postpass
</FORM>
<p> <FORM ACTION="AT-generate$script_suffix" METHOD=POST>
<INPUT TYPE="submit" NAME="Generating" VALUE="Generate">
Generate a search page for this collection.
$postpass
<INPUT TYPE="hidden" NAME="db" VALUE="$form{'dbname'}">
</FORM>
<p> 
<FORM ACTION="AT-admin$script_suffix" METHOD=POST>
<INPUT TYPE="hidden" NAME="db" VALUE="$form{'dbname'}">
<INPUT TYPE="submit" NAME="Admin" VALUE="Admin">
Go back to the admin page for this collection.
$postpass
</FORM><BR>

<p><b>Note:</b>Unless you have
configured this collection $contact_phrase when the indexing process 
is done, you will need to view the log files or visit the admin page
for this collection if you want to know when indexing has finished.
EOF
    ;
    ## Kick off the indexing process here.
    $aindex = $root . "/aindex.pl";
    ## remove any stale .inv files
    unlink("$root/collections/$form{'dbname'}.inv");
    
    &spawn_indexer($aindex, $attr{'PerlRoot'},
		   $form{'dbname'}, "$realpath/$logname",
		   "$realpath/$progname", "$realpath/$errname");

    ## sanity check here to make sure aindex.pl actually ran
    sleep 5; ## give indexer time to create .inv file
    if (! -e "$root/collections/$form{'dbname'}.inv") {
	open(ERRFILE, ">$realpath/$errname");
	print ERRFILE "Error: Cannot invoke aindex.pl\n";
	close(ERRFILE);
	open(ERRFILE, ">$root/collections/$form{'dbname'}.err");
	close(ERRFILE);
    } else {
	unlink("$root/collections/$form{'dbname'}.inv");
    }
	&Architext'Copyright($attr{'ArchitextURL'});
} else {
    ## Print out the top-level screen: scan the root directory for
    ## db.conf files, and allow the user to select a db.conf
    ## file.

    opendir(CONF, "$root/collections");
    @dbconf = grep(/\.conf$/, readdir(CONF));

    &Architext'printHeader($attr{'ArchitextURL'},"Collection Indexing");

    if ($#dbconf > -1) {
    print <<EOF;
<FORM ACTION="AT-index$script_suffix" METHOD=POST>
Choose a document collection to index.<P>
<DL>
<DT> 
Existing <a href="${helppath}AT-helpdoc.html#Document Collections">
document collections:</a> <DD>
<SELECT NAME="db" SIZE=5>
EOF
    ;
    for (@dbconf) {
	s|\.conf$||;
	next if $_ eq 'Architext';
	print "<OPTION> $_\n";
    }
    print <<EOF;
</SELECT>
</DL>
<INPUT TYPE="submit" NAME="Select" VALUE="Select">
$postpass
</FORM><BR>
EOF
    ;
} else {
    print <<EOF;
<p> There are no document collections currently defined.  Please
click on the configure button to go to the collection configuration
screen.
<FORM ACTION="AT-config$script_suffix" METHOD=POST>
<INPUT TYPE="submit" VALUE="Configure">
$postpass
</FORM><BR>
EOF
    ;
}
    &Architext'Copyright($attr{'ArchitextURL'});
}

sub printForm {
    local($db) = shift;
    local($url) = $attr{'ArchitextURL'};
    if ($ews_port eq 'NT') {
	$contact_mode = 
	    "a hostname for a machine running the NT messenger service";
	$contact_method = "the messenger service";
    } else {
	$contact_mode = "an email address";
	$contact_method = "email";
    }
    print <<EOF;
<p> Click on the <b>Index</b> button to start indexing.
Depending on the size of your collection, this may take
anywhere from a few moments to a few hours.
After you initiate the indexing process you will be given links
to several log files that you can reload periodically to monitor the
progress of the indexing process.  If you specified $contact_mode
for this collection, you will also be notified via $contact_method
when the indexing process finishes.
<p><FORM ACTION="AT-index$script_suffix" METHOD=POST>
<INPUT TYPE="submit" NAME="index" VALUE="Index">
Start an indexing process for this collection.
<INPUT TYPE="hidden" NAME="Index" VALUE="Index">
<INPUT TYPE="hidden" NAME="dbname" VALUE="$db">
$postpass
</FORM>

<p> 
<FORM ACTION="AT-admin$script_suffix" METHOD=POST>
<INPUT TYPE="hidden" NAME="db" VALUE="$db">
<INPUT TYPE="submit" NAME="Admin" VALUE="Admin">
Go back to the admin page for this collection.
$postpass
</FORM><BR>
EOF
    ;
}




