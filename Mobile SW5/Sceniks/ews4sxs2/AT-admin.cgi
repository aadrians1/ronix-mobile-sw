#!/bin/sh
perl=/usr/local/www/scenix.com/ews4sxs2/perl
eval "exec $perl -x $0 $*"
#!perl
## Copyright (c) 1996 Excite, Inc.
##
## This CGI script is intended as a first stop for
## administrators of Excite, Inc.'s web site search engine.
##
## This script will appear a several different web pages,
## and will check to make sure that the user has
## registered with Excite, Inc. before providing access
## to the full range of functionality.

BEGIN {
  $root = "/usr/local/www/scenix.com/ews4sxs2";
  die "Invalid root directory '$root'\n" unless -d $root;
  unshift(@INC, "$root/perllib");
}


$| = 1;
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
$news_url = &Architext'newsURL();
$scriptname = "AT-admin$script_suffix";

if ($form{'Version'}) {
    print "Content-type: text/html\n\n"; 
    $version = &Architext'productVersion();
    print "$version\n";
    exit(0);
}

if ($form{'register'} eq 'yes') {
	## given the presence of the register attribute
	## we can assume that the user has registered with
	## Excite, Inc. and is visiting this page for the
	## first time, so we need to update Architext.conf
	## to mark the user as registered.
       $exit = &append_line_to_file("$attr{'ArchitextRoot'}/Architext.conf",
				    "register yes") unless ($attr{'register'});
       &Architext'exitError($attr{'ArchitextURL'},
			    "Unable to update configuration file with registation information. $!") if $exit;
	if ($form{'remote'} eq 'yes') {
	    $exit = &create_empty_file("$attr{'ArchitextRoot'}/.remote")
		unless (-e "$attr{'ArchitextRoot'}/.remote");
	    &Architext'exitError($attr{'ArchitextURL'},
				 "Unable to create .remote file - $!") 
		if $exit;
	}
	if ($form{'at_email'}) {
	    $exit =
		&append_line_to_file("$attr{'ArchitextRoot'}/Architext.conf",
				     "AdminMail $form{'at_email'}") 
		    unless ($attr{'AdminMail'});
	    &Architext'exitError($attr{'ArchitextURL'},
				 "Unable to update configuration file with admin mail address. $!") if $exit;
	}
	## create index.html file with some interesting stuff in it
	%attr = &ArchitextConf'readConfig("$root/Architext.conf");	
	&createIndex($attr{'ConfigRoot'});
	
	## add ServerName, ServerPort, and ServerCgi to .conf file
	&append_line_to_file("$root/Architext.conf", 
			     "ServerName $ENV{'SERVER_NAME'}");
	&append_line_to_file("$root/Architext.conf", 
		     "ServerPort $ENV{'SERVER_PORT'}");
	$server_cgi = $ENV{'SCRIPT_NAME'};
	$server_cgi =~ s/[^\/]+$//;
	$server_cgi =~ s/\/$//;
	&append_line_to_file("$root/Architext.conf", 
			     "ServerCgi $server_cgi");


}

## check for password, if one is specified in Architext.conf
## if it doesn't appear as a form arg, present password page
if ($attr{'register'} =~ /yes/) {
    ## they are registered, so present them with the options
    ## and check for an admin password
    $password = &Architext'password($attr{'ArchitextURL'},
				    $scriptname,
				    $attr{'Password'}, 
				    %form) if $attr{'Password'};
    
    $postpass = 
	"<INPUT TYPE=\"hidden\" NAME=\"$password\" VALUE=\"$attr{'Password'}\">"
	    if ($attr{'Password'}); 
    $getpass = "$password=$attr{'Password'}" if $postpass;
    $getpass = "?" . &Architext'httpize($getpass);

    &createLocalSpiderFile();

    ## allow user to setup file to URL mappings
    if ($form{'Mappings'} eq 'admin') {
	&Architext'printHeader($attr{'ArchitextURL'}, 
			       "Configure URL Mappings");
	$htroot = $attr{'HtmlRoot'};
	$htroot .= "/" unless ($htroot =~ /[\/\\]$/);
	print "<b>Default Mapping: </b>";
	print "<ul>URL prefix '/' <b>maps to filesystem directory</b> '$htroot'</ul>";
	print "<b>Additional Mappings: </b><ul>";
	print "<FORM METHOD=\"POST\" ACTION=\"AT-admin$script_suffix\">";
	print "<TEXTAREA name=\"maps\" ROWS=\"10\" COLS=\"50\">";
	if (-e "$root/url.map") {
	    open(MFILE, "$root/url.map") ||
		&Architext'exitFileError($attr{'ArchitextURL'},
					 "$root/url.map",
					 "could not be opened for reading.");
            while (<MFILE>) {
		print;
            }
	    close(MFILE);
	}
	print <<EOF;
</TEXTAREA><br>
Enter the mappings in the box above with one mapping per line.
The first column is the URL prefix, while the second column is the
directory in the file system that your Web server looks in when serving
URLs with the appropriate prefix in the first column.
$postpass</ul>
<INPUT TYPE="hidden" NAME="Mappings" VALUE="save">
<INPUT TYPE="submit" VALUE="Save Mappings">
Save the mappings described above.
</FORM>
<br>
<FORM ACTION="AT-admin.cgi" METHOD="POST">
$postpass
<INPUT TYPE="submit" VALUE="Main Admin Page">
Don't save, go back to the main administration page.
</FORM>
EOF
    ;
	
	&Architext'Copyright($attr{'ArchitextURL'});
	exit(0);
    }
    if ($form{'Mappings'} eq 'save') {
	&Architext'printHeader($attr{'ArchitextURL'}, 
			       "Save URL Mappings", " ");
	##write the mappings to the URL mapping file, and make sure
	##the format is cool
	unlink("$root/url.map");
	open(MFILE, ">$root/url.map") ||
	    &Architext'exitFileError($attr{'ArchitextURL'},
				     "$root/url.map",
				     "could not be opened for writing.");
	@maps = split('\s+', $form{'maps'});
	while ($file = pop(@maps)) {
	    $url = pop(@maps);
	    $file .= "/" unless ($file =~ /[\/\\]$/);
	    $url .= "/" unless ($url =~ /[\/\\]$/);
	    print MFILE "$url\t$file\n";
	}
	close(MFILE) ||
	    &Architext'exitError($attr{'ArchitextURL'},	
				 "Error writing to file '$root/url.map'");
	print <<EOF;
<h2> Update of URL Mappings was successful.</h2>
<p>
<FORM ACTION="AT-admin.cgi" METHOD="POST">
$postpass
<INPUT TYPE="submit" VALUE="Main Admin Page">
Go back to the main administration page.
</FORM>
EOF
    ;
	&Architext'Copyright($attr{'ArchitextURL'});
	exit(0);
    }
    if ($form{'Mappings'} eq 'seed') {
	&Architext'printHeader($attr{'ArchitextURL'}, 
			       "Configure URL Mappings", " ");
	&Architext'Copyright($attr{'ArchitextURL'});
	exit(0);
    }

    if ($form{'db'}) {
	## db specific admin page
	&Architext'printHeader($attr{'ArchitextURL'}, 
			       "Collection Administration: $form{'db'}");
	print "<hr><b>Collection Status</b><ul>";
	&Architext'printStatus($form{'db'}, $root, $attr{'ConfigRoot'},
			       $attr{'ArchitextURL'}, $helppath,
			       $attr{'CollectionRoot'},
			       $attr{'CgiBin'}, $getpass);
	print <<EOF;
<p><FORM ACTION="AT-admin$script_suffix" METHOD=POST>
<INPUT TYPE="submit" VALUE="Update Status">
Check status information again, in case it has changed.
<INPUT TYPE="hidden" NAME="db" VALUE="$form{'db'}">
$postpass
</FORM><BR>
EOF
    ;
	print "</ul><hr>";
	print <<EOF;
<b>Possible Actions</b><ul>

<FORM ACTION="AT-config$script_suffix" METHOD="POST">
<INPUT TYPE="submit" VALUE="Configure"> 
<INPUT TYPE="hidden" NAME="db" VALUE="$form{'db'}">
Configure the characteristics of this document collection.  
$postpass
</FORM><BR>
EOF
    ;
	## show index or stop index button appropriately
	if (-e "$root/collections/$form{'db'}.pid") {
	    print <<EOF;
<FORM ACTION="AT-index$script_suffix" METHOD=POST>
<INPUT TYPE="submit" NAME="Stop" VALUE="Stop Indexing">
Stop the indexing process that is currently running on this collection.
<INPUT TYPE="hidden" NAME="db" VALUE="$form{'db'}">
$postpass
</FORM><BR>
EOF
    ;
	} else {
	    print <<EOF;
<FORM ACTION="AT-index$script_suffix" METHOD="POST">
<INPUT TYPE="hidden" NAME="db" VALUE="$form{'db'}">
<INPUT TYPE="submit" VALUE="Index"> 
Create an index for this collection.
$postpass
</FORM><BR>
EOF
    ;
	}

	print <<EOF;

<FORM ACTION="AT-generate$script_suffix" METHOD="POST">
<INPUT TYPE="hidden" NAME="db" VALUE="$form{'db'}">
<INPUT TYPE="submit" VALUE="Generate"> Generate the pages
needed to search on this collection.
$postpass
</FORM><BR>
EOF
    ;
	if (-e "$attr{'ConfigRoot'}/AT-$form{'db'}query.html") {
	    print <<EOF;	
<FORM ACTION="$attr{'ArchitextURL'}AT-$form{'db'}query.html" METHOD="GET">
<INPUT TYPE="submit" VALUE="Search">
Make a query on this collection.
</FORM><BR>
EOF
    ;
	}			
    if ((-e "$root/collections/$form{'db'}.pid") ||
	(-e "$root/collections/$form{'db'}.last") ||
	(-e "$root/collections/$form{'db'}.err")) {
	print <<EOF;
<p> <FORM ACTION="AT-generate$script_suffix" METHOD=POST>
<INPUT TYPE="submit" NAME="Status" VALUE="View Logs">
View the log files from the most recent indexing process.
<INPUT TYPE="hidden" NAME="db" VALUE="$form{'db'}">
$postpass
</FORM><BR>
EOF
    ;

    }
    print <<EOF;
<FORM ACTION="AT-admin$script_suffix" METHOD="POST">
<INPUT TYPE="hidden" NAME="dbname" VALUE="$form{'db'}">
<INPUT TYPE="hidden" NAME="Remove" VALUE="Remove">
<INPUT TYPE="submit" VALUE="Remove">
Remove this collection and all files associated with it.
$postpass
</FORM><BR>
<FORM ACTION="AT-admin$script_suffix" METHOD="POST">
<INPUT TYPE="submit" VALUE="Main Admin Page">
Go back to the main administration page.
$postpass
</FORM><BR>
EOF
;
	print "</ul>";
	print "<hr><b>Collection Characteristics</b>\n";
	&Architext'collectionCharacteristics($form{'db'}, $helppath, %attr); 
    } elsif ($form{'Support'} && (! $form{'Confirm'})) {
	## get confirmation and problem description from user 
	## before actually generating info
	&Architext'printHeader($attr{'ArchitextURL'}, 
			       "Create Support Information");

	print <<EOF;
<p> If you are having a problem with this software, you can use
this form to mail a message to excite that will contain a
description of the problem and some additional information that
might be useful in diagnosing your problem.
<FORM ACTION="AT-admin$script_suffix" METHOD=POST>
$postpass
<INPUT TYPE="checkbox" NAME="email" VALUE="email" CHECKED>
Send support information to <b>ewssupport\@excite.com</b>.  If you do not
want the information automatically emailed to excite, uncheck this
box, and a file containing the support information will be created, but
not emailed.
<p>
Please describe the problem you are having in the space provided below:<br>
<TEXTAREA NAME="Description" ROWS=6 COLS=80></TEXTAREA>
<p> Provide an email address for correspondence:
<INPUT NAME="Email" VALUE="$attr{'AdminMail'}" SIZE=40>
<INPUT TYPE="hidden" NAME="Confirm" VALUE="Confirm">
<INPUT TYPE="hidden" NAME="Support" VALUE="Support">
<p><INPUT TYPE="submit" VALUE="Support"> OK, send the information.
</FORM>
<p><FORM ACTION="AT-admin$script_suffix" METHOD=POST>
$postpass
<INPUT TYPE="submit" VALUE="Cancel"> Go back to the main administration page.
</FORM><BR>
EOF
    ;
	&Architext'Copyright($attr{'ArchitextURL'});
	exit 0;			
    } elsif ($form{'Support'} && $form{'Confirm'}) {
        ## send support information to Architext
	&Architext'printHeader($attr{'ArchitextURL'}, 
			       "Done Creating Support Information");
	$version = &Architext'productVersion();
	&create_support_info($root, $attr{'ConfigRoot'}, $version, 
			     $form{'email'}, $form{'Description'});
	if ($form{'email'}) {
	    $email = 
		", and has been sent via email to <b>ewssupport\@excite.com</b>.";
	} else {
	    $email = ".";
	}			

	print <<EOF;

<p> Your support information has been recorded in the file
<b>$root/support.out</b>$email  If your system is not configured to send email
to outside locations, please send the contents of the above file
to ewssupport\@excite.com.  Thank you.
<p>
<FORM ACTION="AT-admin$script_suffix" METHOD=POST>
$postpass
<INPUT TYPE="submit" NAME="GoBack" VALUE="Back To Main Admin Page">
</FORM><BR>
EOF
    ;
	&Architext'Copyright($attr{'ArchitextURL'});
	exit 0;
    } elsif ($form{'Remove'}) {
	## remove collection verb
	&Architext'printHeader($attr{'ArchitextURL'},
			       "Remove Collection: $form{'dbname'}");
	if ($form{'verify'}) {
	    if (-e "$root/collections/$form{'dbname'}.pid") {
		print "<p><b>Sorry, you cannot remove a collection while an index process is running for that collection</b>";
	    } else {
		## no index process is running, so it is safe to
		## remove the collection and all associated files
		%attr = &ArchitextConf'readConfig("$root/Architext.conf", 
						  $form{'dbname'});
		&remove_collection($form{'dbname'}, $root, 
				   $attr{'ConfigRoot'},
				   $attr{'CollectionRoot'},
				   $attr{'CgiBin'});
		print "<p><b>The collection '$form{'dbname'}' has been removed</b>.";
	    }
	    print <<EOF;
<p>
<FORM ACTION="AT-admin$script_suffix" METHOD=POST>
$postpass
<INPUT TYPE="submit" VALUE="Admin">
Go back to the main administration page.
</FORM><BR>
EOF
    ;

	} else {
	    print <<EOF;
Do you really want to remove the configure files, index files, and 
query scripts associated with this collection?
<p>
<FORM ACTION="AT-admin$script_suffix" METHOD=POST>
<INPUT TYPE="hidden" NAME="verify" VALUE="yes">
<INPUT TYPE="hidden" NAME="Remove" VALUE="Remove">
<INPUT TYPE="hidden" NAME="dbname" VALUE="$form{'dbname'}">
$postpass
<INPUT TYPE="submit" VALUE="Remove">
Remove all files associated with this collection.
</FORM>

<p>
<FORM ACTION="AT-admin$script_suffix" METHOD=POST>
<INPUT TYPE="hidden" NAME="db" VALUE="$form{'dbname'}">
$postpass
<INPUT TYPE="submit" VALUE="Admin">
Don't remove files, go back to the administration page for this collection.
</FORM><BR>
EOF
    ;

	}
	&Architext'Copyright($attr{'ArchitextURL'});
	exit(0);
    } elsif ($form{'automate'}) {
	&Architext'printHeader($attr{'ArchitextURL'}, 
			       "Indexing Automation");

	open(AUTO, "$root/AT-automate.html");
	while (<AUTO>) {
	    print;
	}
	close(AUTO);
	print <<EOF;
<hr>
<b>Next step:</b>
<FORM ACTION="AT-admin$script_suffix" METHOD=POST>
$postpass
<INPUT TYPE="submit" VALUE="Admin">
Go back to the main administration page.
EOF
    ;
	&Architext'Copyright($attr{'ArchitextURL'});
	exit(0);
    } else {
	## main admin page
	&Architext'printHeader($attr{'ArchitextURL'},
			       "Excite for Web Servers Administration", " ");
	opendir(CONF, "$root/collections");
	@dbconf = grep(/\.conf$/, readdir(CONF));

	%pubs = &Architext'pubList("$root/collections") 
	    if (&Architext'notifyMode());

	print "<b>Existing <a href=\"${helppath}AT-helpdoc.html#Document Collections\">Document Collections</a></b><ul>";
	
	if ($#dbconf > -1) {
	    for (@dbconf) {
		s|\.conf$||;
		if ($getpass) {
		    $getdb = "&db=$_";
		} else {
		    $getdb = "?db=$_";
		}

                $notify_icon = &Architext'notifyBlankTag($attr{'ArchitextURL'});
                $notify_icon = &Architext'notifyTag($attr{'ArchitextURL'})
                  if $pubs{$_}; 

		print qq(<br>$notify_icon <a href="AT-admin$script_suffix$getpass$getdb">$_</a>\n);
		$status = &Architext'getStatusString($root, $_, 
						     $attr{'ConfigRoot'},
						     $attr{'ArchitextURL'},
						     $attr{'CgiBin'},
						     $getpass);
		print " -- $status \n";
	    }
	    print "</ul>";
	    ## if use of notfier is enabled, present options
	    ## to publish or unpublish a collection
	    if (&Architext'notifyMode()) {
		$notify_icon = &Architext'notifyTag($attr{'ArchitextURL'});
		print <<EOF;
<p><b>Collections marked with a $notify_icon are excite <a href=\"${helppath}AT-helpdoc.html#Notifier\">notifier</a> enabled.</b>

EOF
    ;
	    }

	} else {
	    print "<p>(No document collections found)<p></ul>\n";
	}
	print "<hr>";
	print "<b><a href=\"${helppath}AT-helpdoc.html#New Collection\">New Collection</a></b><ul>";
	print <<EOF;
<p><FORM ACTION="AT-config$script_suffix" METHOD=POST>
Enter a name for a new collection:
<INPUT NAME="new" SIZE=20><br>
<INPUT TYPE="submit" NAME="NewCollection" VALUE="Create New Collection">
<INPUT TYPE="hidden" NAME="admin" VALUE="admin">
$postpass
</FORM><BR>
EOF
    ;

	print "</ul><hr>";

	print "<b> <a href=\"${helppath}AT-helpdoc.html#Support Information\">Support Information </a> </b>"; 
	print "<ul>";
print <<EOF;
<p><FORM ACTION="AT-admin$script_suffix" METHOD=POST>
$postpass
<INPUT TYPE="submit" NAME="Button" VALUE="Create Support Information">
<INPUT TYPE="hidden" NAME="Support" VALUE="Support">
Click here to provide Excite with support information.
</FORM></ul><hr>
<b> <a href="${helppath}AT-helpdoc.html#Changing the Password">
New Password </a> </b><ul>
<FORM ACTION="AT-config$script_suffix" METHOD="POST">
<INPUT TYPE="hidden" NAME="ChangePassword" VALUE="yes">
<INPUT TYPE="hidden" NAME="first" VALUE="yes">
<INPUT TYPE="submit" VALUE="Password">
Change the password used to access this page.
$postpass
</FORM>
</ul>
<hr>
<b> <a href="${helppath}AT-helpdoc.html#Configuring URL Mappings">
Configure URL Mappings </a> </b><ul>
<FORM ACTION="AT-admin$script_suffix" METHOD="POST">
<INPUT TYPE="hidden" NAME="Mappings" VALUE="admin">
<INPUT TYPE="hidden" NAME="first" VALUE="yes">
<INPUT TYPE="submit" VALUE="Configure URL Mappings">
Change, add, or remove URL to filename mappings.
$postpass
</FORM>
</ul>
EOF
    ;
	   
	if ($getpass) {
	    $amper = '&';
	} else {
	    $amper = '?';
	}
    if (!($ews_port eq 'NT')) {
	print <<EOF;		
<hr>
<a href="AT-admin$script_suffix$getpass${amper}automate=automate"><b>Automation Information</b>
</a> Click here for information about scheduling a recurring indexing
process. 

EOF
    ;
    }
    print <<EOF;		
<hr>
<a href="$news_url">
News</a> Check here for up-to-the-minute information about Excite for Web Servers.
<hr>
<a href="$attr{'ArchitextURL'}AT-admininfo.html">
Admin Info Page.</a>  This page is simply
a list of the options you chose at install time; you
can check here to find out where certain files are located in
case you have forgotten. 
EOF
    ;
	&Architext'Copyright($attr{'ArchitextURL'});
	exit 0;
    }



} else {
	## not yet registered, so print out screen to send user
	## back to AT-starthere.html to get them registered and
	## happy before they start using the admin tools
    &Architext'printHeader($attr{'ArchitextURL'}, 
			   "Excite for Web Servers Administration");
	print <<EOF;
<p><h1> Not yet registered. </h1>
<p>  Apparently, you have not yet registered your copy of
this software with Excite, Inc.  To do this, please go to the
<a href="AT-start$script_suffix">getting started</a>
page and follow the instructions presented there. <br>
Thanks!<br>
EOF
;
}

&Architext'Copyright($attr{'ArchitextURL'});


sub createIndex {
    local($location) = @_;
    open(INDEX, ">$location/index.html");
    print INDEX qq(<html><head><title>Excite for Web Servers Administration</title></head>);
    $banner = &Architext'adminBanner();
    print INDEX qq(<body><h1><img src="pictures/$banner">);
    print INDEX qq(<p>Excite for Web Servers</h1>);
    print INDEX qq(<p> Welcome to the Excite for Web Servers administration directory.\n);
    print INDEX qq(From here, you can:); 
    print INDEX qq(<p> Go to the <a href="$ENV{'SCRIPT_NAME'}"> main\n);
    print INDEX qq(administration page</a>.<br>\n);
    print INDEX qq(Go to the <a href="http://www.atext.com">Excite, Inc.);
    print INDEX qq(</a> home page);
    print INDEX qq(<p><p><b>TIP:</b> Make a bookmark for this page, so you can easily get back to the administration page.);
    close(INDEX);
    &make_files_readwriteable("$location/index.html");
}


sub createLocalSpiderFile {
	return if (-e "$root/.first");
	## create a file for local spiders to find
	$server_cgi = $ENV{'SCRIPT_NAME'};
	$server_cgi =~ s/[^\/]+$//;
	$server_cgi =~ s/\/$//;
        open(LSF, ">$root/ews");
        print LSF "$server_cgi\n####EXCLUSIONS####\n";
        close(LSF);
        if (-e "$attr{'HtmlRoot'}/ews") {
          open(TMP, "$attr{'HtmlRoot'}/ews");          
          $hasit = 0;
          while ($str = <TMP>) {
            last if ($str =~ /####EXCLUSIONS####/);
            if ($str eq $server_cgi) {
              $hasit = 1;
              last;
            }
          } 
          close(TMP);
          if (!$hasit) {
            rename("$attr{'HtmlRoot'}/ews", "$attr{'HtmlRoot'}/ews.old");
            open(TMP, "$attr{'HtmlRoot'}/ews.old");                      
            open(NTMP, ">$attr{'HtmlRoot'}/ews");                      
            print NTMP "$server_cgi\n";
            while ($str = <TMP>) {
              print NTMP $str;
            }
            close(NTMP);        
            close(TMP);
            unlink "$attr{'HtmlRoot'}/ews.old";
          }
        }
        else {
          &copy_files("$root/ews", "$attr{'HtmlRoot'}/ews");
        }
	&create_empty_file("$root/.first") unless (-e "$root/.first");	
}
