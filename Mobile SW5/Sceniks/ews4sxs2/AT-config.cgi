#!/bin/sh
perl=/usr/local/www/scenix.com/ews4sxs2/perl
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

BEGIN {
  $root = "/usr/local/www/scenix.com/ews4sxs2";
  $perlportname = "sun4-solaris";
  die "Invalid root directory '$root'\n" unless -d $root;
  if ($perlportname eq "i86pc-solaris") {
    unshift(@INC, "$root/perllib", "$root/perllib/$perlportname/5.00311",
	    "$root/perllib/$perlportname");
  }
  else {
    unshift(@INC, "$root/perllib", "$root/perllib/$perlportname/5.002",
	    "$root/perllib/$perlportname");
  }
}

require 'os_functions.pl';
require 'architext.pl';
require 'architextConf.pl';
require 'architextNotify.pl';
require 'architext_map.pl';

%form = &Architext'readFormArgs;
%attr = &ArchitextConf'readConfig("$root/Architext.conf", $form{'db'});

if (&Architext'remoteMode($root)) {
    $helppath = &Architext'helpPath();
} else {
    $helppath = $attr{'ArchitextURL'};
}

$script_suffix = &Architext'scriptSuffix();
$scriptname = "AT-config$script_suffix";

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

## allow user to change passwords
if ($form{'ChangePassword'} eq 'yes') {
    $warn = &Architext'errorIcon($attr{'ArchitextURL'});
    $message = "";
    if ((! $form{'first'}) && ($form{'pass1'} eq $form{'pass2'})) {
	$newpass = $form{'pass1'};
	$message = "Password cannot contain the '#' character."
	    if ($newpass =~ /\#/);
	$message = "Password cannot contain whitespace characters."
	    if ($newpass =~ /\s/);
	## password is legal, let user know it has been changed
	if (! $message) {
	    &Architext'printHeader($attr{'ArchitextURL'}, "Password Changed");
	    &Architext'updatePassword($root, $newpass, $form{'db'});
	    &make_files_readwriteable("$root/Architext.conf");
	    print <<EOF;
<b>Your password has been updated.</b>

<FORM ACTION="AT-admin$script_suffix" METHOD=POST>
<INPUT TYPE="hidden" NAME="db" VALUE="$form{'dbname'}">
<INPUT TYPE="submit" NAME="Admin" VALUE="Main Admin Page">
Go back to the main administration page.
$postpass
</FORM><BR>

EOF
    ;
	    &Architext'Copyright($attr{'ArchitextURL'});
	    exit(0);
	}
    } else {
	$message = "Passwords didn't match." unless ($message ||
						     ($form{'first'} eq 'yes'));
    }
    ## give user screen to change password for admin or collection
    &Architext'printHeader($attr{'ArchitextURL'}, "Change Password");
    $message = "$warn$message" if $message;
    print <<EOF;
<h2>$message</h2>
<p>Please enter the new password in the spaces provided below. 

<FORM ACTION="AT-config$script_suffix" METHOD="POST">
Enter the password here:<br>
<INPUT NAME="pass1" TYPE="password" SIZE=30>
<p>Enter it again:<br>
<INPUT NAME="pass2" TYPE="password" SIZE=30>
<INPUT TYPE="hidden" NAME="ChangePassword" VALUE="yes">
<INPUT TYPE="hidden" NAME="dbname" VALUE="$form{'db'}">
<INPUT TYPE="hidden" NAME="db" VALUE="$form{'db'}">
<p>
<INPUT TYPE="submit" VALUE="Update Password">  Save the new password.
$postpass
</FORM>

<p>
<FORM ACTION="AT-admin$script_suffix" METHOD=POST>
<INPUT TYPE="submit" NAME="Admin" VALUE="Main Admin Page">
Don't save, go back to the main administration page.
$postpass
</FORM><BR>
EOF
    ;
    &Architext'Copyright($attr{'ArchitextURL'});
    exit(0);
}

## don't allow access if user leaves collection name blank from admin page
if ($form{'admin'} eq 'admin') {
    if (! $form{'new'}) {
	&Architext'printHeader($attr{'ArchitextURL'}, "");
	&Architext'exitError($attr{'ArchitextURL'},
			     "<b>You must provide a name for a new collection.</b>", $postpass);
    }
}


if ($form{'Update'}) {
    ## Assuming all the relevant configuration options are specified
    ## as form arguments, this mode actually writes the db.conf file.
    ## will notify user if required information is missing from
    ## the form by passing a message to the next page
    ## Header again
    ## wrote the http header first to prevent mailer errors from
    ## causing a server error
    &Architext'printHttpHeader;
    if (! ($error_str = &createDbConf())) {
	&Architext'printHeader($attr{'ArchitextURL'}, "Collection Configuration", "Collection Configuration", 'none');

	if (!$form{'dbname'}) { 
	    &Architext'exitError($attr{'ArchitextURL'},
				 "Configure specified with no dbname."); }
	
	## Let the user know the update was a success.
	print "<H2>Configuration successful</H2>\n";
	print "<p><hr>\n";
	if ($getpass) {
	    $getpass .= "&";
	} else {
	    $getpass = "?";
	}
	$getpass .= "db=$form{'dbname'}";
	print <<EOF;
<b>Possible Actions:</b>
<p> <FORM ACTION="AT-index$script_suffix" METHOD=POST>
<INPUT TYPE="submit" NAME="Indexing" VALUE="Index">
Create an index for this collection.
<INPUT TYPE="hidden" NAME="db" VALUE="$form{'dbname'}">
$postpass
</FORM>

<p> 
<FORM ACTION="AT-generate$script_suffix" METHOD=POST>
<INPUT TYPE="submit" NAME="Generation" VALUE="Generate">
Generate search pages for this collection.
<INPUT TYPE="hidden" NAME="db" VALUE="$form{'dbname'}">
$postpass
</FORM>

<p> 
<FORM ACTION="AT-admin$script_suffix" METHOD=POST>
<INPUT TYPE="hidden" NAME="db" VALUE="$form{'dbname'}">
<INPUT TYPE="submit" NAME="Admin" VALUE="Admin">
Go back to the main admin page for this collection.
$postpass
</FORM><BR>
EOF
    ;

	&Architext'Copyright($attr{'ArchitextURL'}); 
	exit(0);
    } else {
	## required elements were not passed in...
	$message = $error_str;
	$form{'db'} = $form{'dbname'};
    }
}

if ($form{'new'}) {
    ## Print out a form to allow the user to create a new database.
    $form{'new'} =~ s/\W+/_/g;

    ## check to see if user has entered name of existing db
    opendir(CONF, "$root/collections");
    @dbconf = grep(/\.conf$/, readdir(CONF));
    for (@dbconf) {
	s|\.conf$||;
	$preexist = 1 if ($form{'new'} eq $_);
	last if $preexist;
    }

    if (! $preexist) {
	## Our standard header
	## VL -- this block fixed extra content-type bug
	if ($form{'Update'})	
	{
	&Architext'printHeader($attr{'ArchitextURL'}, 
			       "Configure New Collection: $form{'new'}",
			       "Configure New Collection: $form{'new'}",
					'none');
	} else
	{
	&Architext'printHeader($attr{'ArchitextURL'}, 
			       "Configure New Collection: $form{'new'}");

	}
	## fixed code end 
	$warn = &Architext'errorIcon($attr{'ArchitextURL'});
	print "<p>$warn<b>ATTENTION: $message Please try again.</b>" if $message;
	
	## Read the default configuration information.
	##%attr = &ArchitextConf'readConfig("$root/Architext.conf");
	
	## Print the form.
	&printForm($form{'new'}, $form{'new'});
	&Architext'Copyright($attr{'ArchitextURL'});
	exit(0);
    } else {
	$form{'db'} = $form{'new'};
	$message = "<b>You chose a name for the new collection that was already in use by an existing collection.</b>  Go back if you want to create a new collection, otherwise, you can now configure the collection whose name you specified.";
	%attr = &ArchitextConf'readConfig("$root/Architext.conf", $form{'db'});
  ## VL - Added this to fix create with same index name bug
  &Architext'printHttpHeader;
    }
    
}  
if ($form{'db'}) {
    ## Print out configuration options for an already-existing
    ## database, and allow the user to update the options.

    ## Dump our standard header
    &Architext'printHeader($attr{'ArchitextURL'}, 
			   "Collection Configuration: $form{'db'}", 
			   "Collection Configuration: $form{'db'}", 
			   $message);

    $warn = &Architext'errorIcon($attr{'ArchitextURL'});
    ## print a message from the Update mode if something was missing
    print "$warn<b>ATTENTION: $message</b>" if $message;

    ## Check for the desired database.conf file.
    $dbconfig = $root . "/collections/" . $form{'db'} . ".conf";
    if (! -r $dbconfig) { 
	&Architext'exitFileError($dbconfig, "does not exist"); 
    }

    ## Read all the configuration information.
    ##%attr = &ArchitextConf'readConfig("$root/Architext.conf", $form{'db'});

    ## Print the form.
    &printForm($form{'db'});
    &Architext'Copyright($attr{'ArchitextURL'});
    
} else { 
  ## Print out the top-level screen: scan the root directory for 
  ## db.conf files, and allow the user to initialize a new db.conf file.

    opendir(CONF, "$root/collections");
    @dbconf = grep(/\.conf$/, readdir(CONF));

    &Architext'printHeader($attr{'ArchitextURL'}, "Collection Configuration");
    print <<EOF;
<FORM ACTION="AT-config$script_suffix" METHOD=POST>
Choose a document collection to configure, or enter a new collection:<P>
<DL>
<DT> Existing 
<a href="${helppath}AT-helpdoc.html#Document Collections">
document collections:</a> <DD>
EOF
    ;
    if ($#dbconf > -1) {
	print "<SELECT NAME=\"db\" SIZE=5>"; 

	for (@dbconf) {
	    s|\.conf$||;
	    next if $_ eq 'Architext';
	    print "<OPTION> $_\n";
	}
	print "</SELECT><P>\n";
    } else {
	print "<p>(No document collections found)<p>\n";
    }

    print <<EOF;		
<DT> If you wish to configure a 
<a href="${helppath}AT-helpdoc.html#New Collection">
new collection</a> 
please supply a name for it here. <DD> <INPUT NAME="new">
</DL>
<INPUT TYPE="submit" NAME="Configure" VALUE="Configure">
$postpass
</FORM><BR>
EOF
    ;

    &Architext'Copyright($attr{'ArchitextURL'});
}

## Prints an input line for a form.
sub printInputLine {
    local($name, $text, $db) = @_;
    local($val);
    local($size);
    $text = $name unless $text;
    $val = eval "\$attr{$name}";
    $val = "$attr{'ArchitextRoot'}/collections/" if $db;
    $val = $form{$name} if $form{$name};
    $size=40;
    $size = (length($val) +10) unless ((length($val) +10) < 40);
    print <<EOF;
<a href="${helppath}AT-helpdoc.html#$text">$text:</a> 
<INPUT NAME="$name" VALUE="$val" SIZE=$size><P>
EOF
    ;
}

## Prints out the Architext form. Uses dynamic scoping to ensure that
## the values in the %attr array are properly set.
sub printForm {
    local($db, $new) = @_;
    local($files, $rules);
    local($fileval, $ruleval, $filter_html, $filter_both, $notify_check);
    print "<p>Please use absolute pathnames for filenames.\n";
    print qq(<FORM ACTION="AT-config$script_suffix" METHOD=POST>\n);
    &printHiddenLine('CollectionInfo', 'CollectionInfo', "$db.cf");    
    if ($new) {
	print qq(<INPUT TYPE="hidden" NAME="new" VALUE="$new">);
    }
    print "Designate the directory where the index files will be stored.\n";
    print "Make sure there is enough space on the directory to accomodate the index files, which will be about 50 percent of the total size of the files you index during indexing, and 15 percent once indexing has completed.<br>\n";
    &printInputLine('CollectionIndex', 'CollectionIndex', $db);
    $filterstring = "$form{'IndexFilterHTML'}$form{'IndexFilterTEXT'}$form{'IndexFilterBIN'}$form{'IndexFilterCUST'}";
    $ifilter = $filterstring || $attr{'IndexFilter'};
    $ifilter = 'HTMLTEXT' unless $ifilter; ##default to html and text
    $custfilter = $form{'ExclusionRules'} || $attr{'ExclusionRules'};
    $custsize = length($custfilter) + 10;
    $custsize = 50 unless ($custsize > 50);
    if ($ifilter =~ /^Text/) {
	## These set for back-compatibility reasons
	$filter_text = "CHECKED";
	$filter_html = "CHECKED";
    } 
    if ($ifilter =~ /^HTML/) {
	$filter_html = "CHECKED";
    } 
    if ($ifilter =~ /TEXT/) {
	$filter_text = "CHECKED";
    }
    if ($ifilter =~ /PDF/) {
	$filter_pdf = "CHECKED";
    }
    if (($ifilter =~ /CUST/) || $custfilter) {
	$filter_cust = "CHECKED";
    }

    
    $form{'FileListCheck'} = 'yes' if ($attr{'CollectionsContents'} =~ /^\+/);
    $files = "CHECKED" if ($form{'FileListCheck'} ||
			   $attr{'FileList'} || $form{'FileList'});
    $rules = "CHECKED" if (($attr{'CollectionContents'} # 
			    && ($attr{'CollectionContents'} !~ /^\+/))
			   || $form{'FileSource'}); 
    if ($files) {		
	$fileval = $form{'FileList'} || $attr{'FileList'};
	$fileval2 = $attr{'CollectionContents'} if ($attr{'CollectionContents'} =~ /^\+/);
	$fileval = $fileval2 unless $fileval; 
	$fileval =~ s/^\+//;	
    }				

    $ccontents = $form{'CollectionContents'};
    if (! $form{'CollectionContents'}) {
	$ccontents = $attr{'CollectionContents'} unless
	    ($attr{'CollectionContents'} =~ /^\+/);
    }
    

    $ruleval = join("\n", &splitFileList($ccontents)) if $rules;

    $notify_check = "CHECKED" if ((-e "$root/collections/$form{'db'}.pub") ||
                                  ($form{'notify'} eq "NOTIFY"));

print <<EOF;
<hr>
<b> Choose the Files to Index </b>
<p> Describe the <a href="${helppath}AT-helpdoc.html#CollectionContents">
CollectionContents</a> (the files you wish to index) using any combination
of the three options provided below:
<p><INPUT TYPE="checkbox" NAME="FileSource" VALUE="FileSource" $rules>
<b> Enter the Files to Index Directly into this Form</b><ul>
Index the files and directories listed here: <br>
<TEXTAREA NAME="CollectionContents" ROWS=4 COLS=60>$ruleval</TEXTAREA></ul>
<p><INPUT TYPE="checkbox" NAME="FileListCheck" VALUE="FileList" $files>
<b> Index Using File List </b><ul>
Index the files and directories listed in the following file:
<INPUT NAME="FileList" VALUE="$fileval" SIZE=30><br>
Filenames must be listed using absolute pathnames, with one
filename per line.
</ul>
EOF
    ;
    ##indexing option to allow index of ~user dirs
    if (&Architext'indexUserDirs() && (! ($ews_port eq 'NT'))) {
	$user_val = 'CHECKED' if ($form{'user_dirs'} || $attr{'PublicHtml'});
	$public_html = $form{'PublicHtml'} || $attr{'PublicHtml'} ||
	    'public_html';
	$pub_size = length($public_html) + 10;
	print <<EOF;
<INPUT TYPE="checkbox" NAME="user_dirs" VALUE="yes" $user_val>
<b> Index ~user Directories</b>
<ul>
    In addition to the files specified above, index the files in
the following subdirectory of each user's home directory:
<INPUT NAME="PublicHtml" VALUE="$public_html" SIZE="$pub_size">
</ul>
EOF
    ;
    }
    print <<EOF;
<hr>
<b>Index Filter</b>
<ul>Configure the <a href="${helppath}AT-helpdoc.html#IndexFilter">
IndexFilter</a> (the types of files you wish to include in 
the index.):<br>
<INPUT TYPE="checkbox" NAME="IndexFilterHTML" VALUE="HTML" $filter_html>
HTML Files (filenames with a <b>.*htm*</b> suffix)<br>
EOF
;
    &Architext'additionalOptions($filter_pdf);
    print <<EOF;
<INPUT TYPE="checkbox" NAME="IndexFilterTEXT" VALUE="TEXT" $filter_text>
Text Files<br>
<INPUT TYPE="checkbox" NAME="IndexFilterCUST" VALUE="CUST" $filter_cust>
Files that match user-defined expressions in the 
<a href="${helppath}AT-helpdoc.html#Custom Filter File">Custom Filter File</a>
designated below:
<ul><INPUT NAME="ExclusionRules" VALUE="$custfilter" SIZE=$custsize></ul>
</ul>
<p>
</ul>
<hr>
EOF
    ;
    if (&Architext'inlineSummaryMode()) {
	$fast_check = "CHECKED" 
	    if (($form{'SummaryMode'} eq 'fast') ||
		($attr{'SummaryMode'} eq 'fast'));
	$q_check = "CHECKED" 
	    if (($form{'SummaryMode'} eq 'quality') ||
		($attr{'SummaryMode'} eq 'quality'));
	print <<EOF;
<a href="${helppath}AT-helpdoc.html#Summary Mode"><b>Summary Mode</b></a><br>
<ul>
Choose a summary mode.  Summaries are generated at indexing time, and 
therefore impact indexing speed.<br>
<INPUT TYPE="RADIO" NAME="SummaryMode" VALUE="fast" $fast_check>
Fast summaries.  (Just the first few lines from the file.)<br>
<INPUT TYPE="RADIO" NAME="SummaryMode" VALUE="quality" $q_check>
Quality summaries.  (These summaries are calculated using excite's
summarization technology.  These are generally better descriptions than
the first two lines of the file, but do slow down indexing a bit.
</ul>
<hr>
EOF
    ;
    }
	if (&Architext'externalSitesMode()) {
	    $spider_dir = $form{'SpiderDir'} || $attr{'SpiderDir'};
	    $spider_dir_length = length($spider_dir);
	    $spider_dir_length = 30 if ($spider_dir_length < 30); 
	    print <<EOF;
<a href="${helppath}AT-helpdoc.html#Spider Directory">
<b>Spider Directory</b></a><br>
<ul>
Enter the name of a directory where the spider's output is stored:
<INPUT NAME="SpiderDir" VALUE="$spider_dir" SIZE="$spider_dir_length">
</ul>
<hr>
EOF
    ;
	}

    if (&Architext'notifyMode()) {
print <<EOF;
<INPUT TYPE="checkbox" NAME="notify" VALUE="NOTIFY" $notify_check>
<b> Participate in excite <a href=\"${helppath}AT-helpdoc.html#Notifier\">notifier</a></b>
<ul>
Please provide an email address below that works from outside your site.
<br>
</ul>
<hr>
EOF
    ;
}
if (&os_name() eq 'NT') {
	$server_name = $ENV{'SERVER_NAME'};
	$server_name =~ s/\..*$//g;
	print <<EOF;
If you would like to be notified via the NT Messenger Service 
when an indexing process on this collection completes, provide a hostname 
here.  <b><i>Please be sure that the NT Messenger Service is
running on that machine.</b></i>
<br>
<a href="${helppath}AT-helpdoc.html#IndexingContact">
IndexingContact:</a>
<INPUT NAME="AdminMail" SIZE=40 VALUE="$server_name">
EOF
    ;
    } else {
	$admin_mail = $form{'AdminMail'} || $attr{'AdminMail'};
	print <<EOF;
<p>If you would like to receive email notification when the indexing 
process completes, provide an address here.<br>
<a href="${helppath}AT-helpdoc.html#IndexingContact">
IndexingContact:</a>
<INPUT NAME="AdminMail" SIZE=40 VALUE="$admin_mail">
EOF
    ;
    }
    if (&Architext'customFormat()) {
	$title_delimiter = $form{'TitleDelimiter'} || $attr{'TitleDelimiter'};
	$doc_delimiter = $form{'DocumentDelimiter'} || 
	    $attr{'DocumentDelimiter'};
	$dd_size = 
	    (length($doc_delimiter) > 30) ? length($doc_delimiter)+5 : 30;
	$td_size = 
	    (length($title_delimiter) > 30) ? length($title_delimiter)+5 : 30;
	
	print <<EOF;
<hr> <b> Custom Document Format Information </b>
<ul>
Specify the <a href="${helppath}AT-helpdoc3.html#Document Delimiter">
document delimiter</a>: <INPUT NAME="DocumentDelimiter"
VALUE="$doc_delimiter" SIZE=$dd_size>
<p>Specify the <a href="${helppath}AT-helpdoc3.html#Title Delimiter">
title field delimiter</a>: <INPUT NAME="TitleDelimiter" 
VALUE="$title_delimiter" SIZE=$td_size>
</ul>
EOF
    ;
    }
    print <<EOF;
<hr>
<b>Possible Actions:</b>
<p><INPUT TYPE="submit" NAME="Set" VALUE="Save">
Save the configuration characteristics for this collection.
<INPUT TYPE="hidden" NAME="Update" VALUE="Update">
<INPUT TYPE="hidden" NAME="dbname" VALUE="$db">
<INPUT TYPE="hidden" NAME="db" VALUE="$db">
$postpass
</FORM><BR>
EOF
    ;

    if (-e "$root/collections/$db.conf") {
	$dbline = "<INPUT TYPE=\"hidden\" NAME=\"db\" VALUE=\"$db\">";
    }
    print <<EOF;
<p> 
<FORM ACTION="AT-admin$script_suffix" METHOD=POST>
$dbline
<INPUT TYPE="submit" NAME="Admin" VALUE="Admin">
Don't save, go back to the admin page.
$postpass
</FORM><BR>
EOF
    ;
}

## pass around all the parameters that user doesn't need to see
sub printHiddenLine {
    local($name, $value, $dummy) = @_;
    if (!&Architext'debugMode())
    {
	$val = eval "\$attr{$name}";
	$val = "$attr{'ArchitextRoot'}/collections/$dummy" if $dummy;
	print qq(<INPUT TYPE="hidden" NAME="$name" VALUE="$val">);
    }
    else
    {
	&printInputLine($name, $value, $dummy);
    }				
}


## writes a db conf file to disk and does some error checking
## to make sure that the user has entered sensible values.
## also adds the AdminMail field to Architext.conf if it is
## not already there, so that it will be defaulted in the
## future
sub createDbConf {
    local($dbconfig, $message, $collection_root, $exit, @index);
    local($n_do, $n_exist, $n_mail, $n_port, $n_server, $n_cgdir, %n_attr);
    if (!$form{'CollectionIndex'}) {
	return "You cannot leave the 'CollectionIndex' field blank.";
    } 
    return "You must choose the files you wish to index." 
	unless ($form{'user_dirs'} || $form{'FileListCheck'} ||
		$form{'FileSource'} || $form{'SpiderDir'});
    if ($form{'FileListCheck'}) {
	return "You must supply a filename for the file list." 
	    unless $form{'FileList'};
	return "The file list file '$form{'FileList'}' does not exist."
	    unless (-e $form{'FileList'});
	return "The file list file '$form{'FileList'}' is not readable."
	    unless (-r $form{'FileList'});
    }
    if ($form{'FileSource'}) {
	return "You must supply filenames for the files you wish to index."
	    unless $form{'CollectionContents'};
    }
    ## add rootnmame to collection index path
    $dbconfig = $root . "/collections/" . $form{'dbname'} . ".conf";
    $form{'CollectionIndex'} .= "/" unless $form{'CollectionIndex'} =~ /\/$/;
    $collection_root = "$form{'CollectionIndex'}$form{'dbname'}";
    ## Can we write to the db.conf file?
    if (-e $dbconfig && ! -w $dbconfig) {
	&Architext'printHeader($attr{'ArchitextURL'}, "Error");
	&Architext'exitFileError($attr{'ArchitextURL'}, 
				 $dbconfig, "is not writable.");
    }

    if ($form{'SpiderDir'}) {
	return "The spider output directory '$form{'SpiderDir'}' does not exist." unless (-e $form{'SpiderDir'});
	return "The spider output directory '$form{'SpiderDir'}' is not a directory" unless (-d $form{'SpiderDir'});
    }

    ## test user's entries to make sure they are valid
    ## makes sense and will not be likely to kill the indexing
    ## process.
    if ($form{'user_dirs'}) {
	return "You must provide a name for the subdirectory where user's HTML files are stored." unless $form{'PublicHtml'};
    }
    return "The index binary '$attr{'IndexExecutable'}' does not exist."
	if ((! -e $attr{'IndexExecutable'}) && 
	    (! -e "$attr{'IndexExecutable'}.exe"));
    return "The  search binary '$attr{'SearchExecutable'}' does not exist."
	if ((! -e $attr{'SearchExecutable'}) &&
	    (! -e "$attr{'SearchExecutable'}.exe"));
    return "The stem table '$attr{'StemTable'}' is not readable."
	if (! -r $attr{'StemTable'}); 
    return "The stop table '$attr{'StopTable'}.key' is not readable."
	if (! -r "$attr{'StopTable'}.key");  
    return "The stop table '$attr{'StopTable'}.ptr' is not readable."
	if (! -r "$attr{'StopTable'}.ptr"); 
    return "The CollectionIndex directory you specified ($form{'CollectionIndex'}) does not exist."
	if (! -e $form{'CollectionIndex'});
    return "The CollectionIndex directory you specified ($form{'CollectionIndex'}) is not a directory."
	if (! -d $form{'CollectionIndex'});
    return "The CollectionIndex directory you specified ($form{'CollectionIndex'}) is not writeable."
	if (! -w $form{'CollectionIndex'});
    return "You must choose at least one of the IndexFilter options."
	unless ($form{'IndexFilterHTML'} || $form{'IndexFilterTEXT'}
		|| $form{'IndexFilterBIN'} || $form{'IndexFilterCUST'}
		|| $form{'IndexFilterPDF'});
    if (($form{'IndexFilterCUST'}) && (!$form{'ExclusionRules'})) {
	return "You must supply the name of Custom Filter File.";
    }
    if ($form{'ExclusionRules'} && ($form{'IndexFilterCUST'})) {
	return "The Custom Filter File you specified ($form{'ExclusionRules'}) does not exist."
	    if (! -e $form{'ExclusionRules'});
	return "The Custom Filter File you specified ($form{'ExclusionRules'}) is not readable."
	    if (! -r $form{'ExclusionRules'});
    }
    if ($form{'FileListCheck'}) {
	return "You must provide the name of a file list." 
	    unless ($form{'FileList'});
	return 
	    "The file list '$form{'FileList'}' you specified does not exist." 
		unless (-e $form{'FileList'});	
	$form{'FileList'} =~ s/^\s+//;
	$form{'FileList'} =~ s/\s+$//;
	return "Please specify only one file list file." if ($form{'FileList'} =~ /\S\s\S/);
    } else {
	$form{'CollectionContents'} = join(" ", &splitFileList($form{'CollectionContents'}));
    }
    %url_maps = &ArchitextMap'getMappings($attr{'HtmlRoot'}, "$root/url.map");
    @index = &splitFileList($form{'CollectionContents'});
    for (@index) {
	if (/^\+/) {
	    if ($form{'FileSource'} eq 'Files') {
		return "Bad filename given.  ($_) Please use absolute pathnames.";
	    }
	    s/^\+//;
	    return "Could not find file list '$_'.  Please re-enter the file list filename."
		if (! -e $_);
	    return "Could not read from file list '$_'.  Please re-enter the file list filename."
		if (! -r $_);
	    ## check to to enforce files in file list appear under html root
	    open(FLIST, "$_");
	    while (<FLIST>) {
		if (! &Architext'underRoot($_, $ews_port || '*', %url_maps)) {
		    close(FLIST);
		    return "The file '$_' specified in the file list does not appear under your html root directory or any of the directories mentioned in your URL Mapping configuration.  Please specify files that appear under these directories, or your Web server will not have access to them.";
		}
	    }
	    close(FLIST);
	} else {
	    ## check here to enforce that files appear under html root
	    return "Specified file or directory '$_'  does not appear under your html root directory or any of the directories mentioned in your URL Mapping configuration.  Please specify files that appear under your these directories, or your Web server will not have access to them." unless &Architext'underRoot($_, $ews_port || '*', %url_maps);
	    return "Specified file or directory '$_' does not exist.  Please re-enter the list of files to index."
		if (! -e $_);
	    return "Could not read from the specified file or directory '$_'.  Please re-enter the list of files to index."
		if (! -r $_); 
	}
    }
    
    if (&Architext'notifyMode()) {
 
	$n_do = 0;
	$n_exist = 0;
	$n_do = 1 if ($form{'notify'} eq "NOTIFY");
	$n_exist = 1 if (-e "$root/collections/$form{'dbname'}.pub");
	
	$n_mail = $form{'AdminMail'};
	$n_port = $ENV{'SERVER_PORT'} || $attr{'ServerPort'}; 
	$n_server = $attr{'ServerName'};
	$n_cgdir  = $attr{'ServerCgi'};
	$n_server = $n_server . ":" . $n_port if ($n_port);
	
	if ($n_exist && !$n_do) {
	    unlink "$root/collections/$form{'dbname'}.pub";
	    
	    &ArchitextNotify'notify($form{'dbname'}, "OFF");
	    
	    $mailapp = &mailer($root);
	    open(MAIL, "| $mailapp ews_notify\@atext.com");
	    print MAIL "To: ews_notify\@atext.com\n";
	    print MAIL "Subject: Architext notifier UNSUBSCRIBE\n";
	    print MAIL "Collection: $form{'dbname'}\n";
	    print MAIL "Server: $n_server\n";
	    print MAIL "CgiBin: $n_cgdir\n";
	    print MAIL "AdminMail: $n_mail\n";
	    close MAIL;
	}
	
	if ($n_do && !$n_exist) {
	    if ($form{'AdminMail'} !~ /\@/) {
		return "Please supply an email address that works from outside your organization when choosing to participate in the notifier";
	    }
	    if (! open(TMP, ">$root/collections/$form{'dbname'}.pub")) {
		&Architext'exitFileError($attr{'ArchitextURL'}, 
					 "$root/collections/$form{'dbname'}.pub",
					 "could not be opened for writing."); 
	    }
	    close TMP;
	    
	    &ArchitextNotify'notify($form{'dbname'}, "ON");
	    
	    open(MAIL, "| mail ews_notify\@atext.com");
	    print MAIL "To: ews_notify\@atext.com\n";
	    print MAIL "Subject: Architext notifier SUBSCRIBE\n";
	    print MAIL "Collection: $form{'dbname'}\n";
	    print MAIL "Server: $n_server\n";
	    print MAIL "CgiBin: $n_cgdir\n";
	    print MAIL "AdminMail: $n_mail\n";
	    close MAIL;
	    
	}
	
    }
    
    if (! open(DBCONF, ">$dbconfig")) {
	&Architext'exitFileError($attr{'ArchitextURL'}, 
				 $dbconfig, 
				 "could not be opened for writing."); 
    }				
    
    ## now that everything has been tested for accuracy, write to disk
    print DBCONF "<Collection $form{'dbname'}>\n";
    for ('CollectionIndex', 'CollectionInfo') {
	print DBCONF "$_ $form{$_}\n"; 
    }
    $filterstring = "$form{'IndexFilterHTML'}$form{'IndexFilterTEXT'}$form{'IndexFilterBIN'}$form{'IndexFilterCUST'}$form{'IndexFilterPDF'}";
    print DBCONF "IndexFilter $filterstring\n";
    $form{'CollectionContents'} = "" unless $form{'FileSource'};
    print DBCONF "CollectionContents $form{'CollectionContents'}\n";
    print DBCONF "FileList $form{'FileList'}\n" if $form{'FileListCheck'};
    if ($form{'user_dirs'}) {
	&generateUserFile("$root/collections/$form{'dbname'}.usr",
			  $form{'PublicHtml'});
	print DBCONF "PublicHtml $form{'PublicHtml'}\n";
    }
    print DBCONF "CollectionRoot $collection_root\n";
    print DBCONF "AdminMail $form{'AdminMail'}\n";
    print DBCONF "ExclusionRules $form{'ExclusionRules'}\n" if ($form{'ExclusionRules'} && $form{'IndexFilterCUST'});
    print DBCONF "SpiderDir $form{'SpiderDir'}\n" if $form{'SpiderDir'};
    if ($form{'SummaryMode'}) {
	print DBCONF "SummaryMode $form{'SummaryMode'}\n";
	$num_sum_sent = &Architext'numSumSent();
	print DBCONF "NumSumSent $num_sum_sent\n";
    }
    if (&Architext'customFormat()) {
	print DBCONF "DocumentDelimiter $form{'DocumentDelimiter'}\n" 
	    if $form{'DocumentDelimiter'};
	print DBCONF "TitleDelimiter $form{'TitleDelimiter'}\n"
	    if $form{'TitleDelimiter'};
	if ($form{'TitleDelimiter'} || $form{'DocumentDelimiter'}) {
	    if (! open(CUSTOM, ">$root/collections/$form{'dbname'}.cus")) {
		&Architext'printHeader($attr{'ArchitextURL'}, "Error");	
		&Architext'exitFileError($attr{'ArchitextURL'},
					 "$root/collections/$form{'dbname'}.cus",
					 "Could not be opened for writing");
	    }
	    print CUSTOM "$form{'DocumentDelimiter'}\n";
	    print CUSTOM "$form{'TitleDelimiter'}\n";
	    close(CUSTOM);
	}
    }
    print DBCONF "ServerPort $ENV{'SERVER_PORT'}\n";
    print DBCONF "</Collection>\n";
    close(DBCONF);
    ## put AdminMail in Architext.conf if it is not already there
    if ($form{'AdminMail'} && (! $attr{'AdminMail'})) {
	$exit = &append_line_to_file("$root/Architext.conf", 
				     "AdminMail $form{'AdminMail'}");
	&Architext'exitError($attr{'ArchitextURL'},
			     "Error updating Architext.conf with AdminMail - $!") if $exit;
    }
    return($message);
}
 
## grabs user info from /etc/passwd for indexing of
## user's public_html directories
sub generateUserFile {
    local($filename, $subdir) = @_;
    local($user, $dir, $file, $filename2);
    local(%homedirs) = &getHomeDirs();
    $filename2 = $filename;
    $filename2 .= "2";
    unlink($filename);
    unlink($filename2);
    open(USERFILE, ">$filename");
    open(UFILE, ">$filename2");
    foreach $user (keys %homedirs) {
	$file = $homedirs{$user};
	$file .= "/" unless ($file =~ /\/$/);
	$file .= $subdir;
	$file .= "/" unless ($file =~ /\/$/);
	if (-e $file) {
	    print USERFILE "~$user $file\n";
	    print UFILE "$file\n";
	}
    }
    close(USERFILE);
    close(UFILE);
}

## gets the home directories for all the users on the server
sub getHomeDirs {
	local(%homes);
	local($name, $passwd, $uid, $gid, $quota, $comment, $gcos, $dir, $shell);
	local($members);
	# local($group) = "sysadmin";
	local($group) = "real";
	($name, $passwd, $gid, $members) = getgrnam($group);
	if ($name eq $group) {
		local(@members) = split(/\s/, $members);
		foreach $name (@members) {
			($name, $passwd, $uid, $gid, $quota, $comment, $gcos, $dir, $shell) = getpwnam($name);
			$homes{$name} = $dir if $name;
		}
	}
	else {
		while (($name, $passwd, $uid, $gid, $quota, $comment, $gcos, $dir, $shell) = getpwent) {
			next if $passwd eq "*";
			next unless $shell =~ /sh$/;
			next if $dir eq "/";
			next if $dir =~ /tmp/; 
			next unless ((-f "$dir/.cshrc") || (-f "$dir/.login")); 
			$homes{$name} = $dir; 
		}
		##endpwent; ## perl bug?  causes bad free().
	}
	%homes;
}



