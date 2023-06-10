#!/bin/sh
perl=/usr/local/www/scenix.com/ews4sxs2/perl
eval "exec $perl -x $0 $*"
#!perl

## Copyright (c) 1996 Excite, Inc.
##
## This CGI script allows users to generate an Excite, Inc. database
## query page and result page. Naturally, there are plenty of security
## concerns associated with this scheme.
##
## This script appears as several different web pages, depending on
## its invocation. If invoked with a 'db=<database>' argument, the
## script prints out the configuration information for a particular
## database and then allows the user to input a description of the
## database for the pages it will generate. If
## invoked with 'Generate=Generate', 'dbname=<database>',
## 'describe=<description>', and 'unprefix=<unprefix>' 
## it will generate files for a database which has an existing database 
## configuration file. 
## Without any of these arguments, it displays a list of currently 
## existing database.conf files, and allows the user to choose a database 
## for which to generate pages.

BEGIN {
  $root = "/usr/local/www/scenix.com/ews4sxs2";
  die "Invalid root directory '$root'\n" unless -d $root;
  unshift(@INC, "$root/perllib");
}

$| = 1;  ## don't buffer output

require 'os_functions.pl';
require 'architext.pl';
require 'architextConf.pl';
require 'architext_map.pl';

$query_banner = &Architext'queryBanner();

%form = &Architext'readFormArgs;
$form{'db'} = $form{'dbname'} unless $form{'db'};
%attr = &ArchitextConf'readConfig("$root/Architext.conf", $form{'db'});

if (&Architext'remoteMode($root)) {
    $helppath = &Architext'helpPath();
} else {
    $helppath = $attr{'ArchitextURL'};
}

$script_suffix = &Architext'scriptSuffix();
$scriptname = "AT-generate$script_suffix";

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

## remind users where they need to move generated scripts
if ($form{'moveinfo'}) {
    &Architext'printHeader($attr{'ArchitextURL'},
			   "About Moving Query Scripts");
    $search = "<b>AT-$form{'dbname'}search$script_suffix</b>";
    
    print <<EOF;
<p> You have generated the appropriate script necessary to perform
searches on this collection, but they must be moved to your
<b>cgi-bin</b> directory before you can actually begin searching.
<p> Copy $search $gather from <b>$attr{'ConfigRoot'}</b> to
<b>$attr{'CgiBin'}</b>, and you will able to start searching on your
collection.

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
    exit;
}

if ($form{'Dump'}) {
    &Architext'printHeader($attr{'ArchitextURL'},
			   "View $form{'Type'} logfile");

    if (! -e $form{'File'}) {
	&Architext'exitError($attr{'ArchitextURL'},
			     "Couldn't find '$form{'File'}'");
    }
    print "<hr><b>Collection Status</b><ul>\n";
    &Architext'printStatus($form{'db'}, $root, $attr{'ConfigRoot'},
			       $attr{'ArchitextURL'}, $helppath,
			       $attr{'CollectionRoot'},
			       $attr{'CgiBin'});
    print "</ul><hr>\n";
    print "\n<pre>\n";
    open(LOG, "$form{'File'}");
    while (<LOG>) {
	print;
    }
    close(LOG);
    print "\n</pre>\n<hr>";
    $filestub = $form{'File'};
    $filestub =~ s|\.\w{3,4}$||;
    print <<EOF;
<b>Possible Actions:</b>
<p><FORM ACTION="AT-generate$script_suffix" METHOD=POST>
<INPUT TYPE="hidden" NAME="db" VALUE="$form{'db'}">
<INPUT TYPE="submit" NAME="Reload" VALUE="Reload">
Reload this page, in case the log file or status  has changed.
<INPUT TYPE="hidden" NAME="Dump" VALUE="dummy">
<INPUT TYPE="hidden" NAME="File" VALUE="$form{'File'}">
<INPUT TYPE="hidden" NAME="Type" VALUE="$form{'Type'}">
$postpass
</FORM><BR>

EOF
    ;
    if (! ($form{'Type'} eq 'progress')) {
	print <<EOF;
<p><FORM ACTION="AT-generate$script_suffix" METHOD=POST>
<INPUT TYPE="hidden" NAME="db" VALUE="$form{'db'}">
<INPUT TYPE="submit" NAME="Progress" VALUE="Progress">
Show the contents of the progress log file.
<INPUT TYPE="hidden" NAME="Dump" VALUE="dummy">
<INPUT TYPE="hidden" NAME="File" VALUE="$filestub.prog">
<INPUT TYPE="hidden" NAME="Type" VALUE="progress">
$postpass
</FORM><BR>

EOF
    ;
    }
    if (! ($form{'Type'} eq 'verbose')) {
	print <<EOF;
<p><FORM ACTION="AT-generate$script_suffix" METHOD=POST>
<INPUT TYPE="hidden" NAME="db" VALUE="$form{'db'}">
<INPUT TYPE="submit" NAME="Verbose Log" VALUE="Verbose Log">
Show the contents of the verbose log file.
<INPUT TYPE="hidden" NAME="Dump" VALUE="dummy">
<INPUT TYPE="hidden" NAME="File" VALUE="$filestub.log">
<INPUT TYPE="hidden" NAME="Type" VALUE="verbose">
$postpass
</FORM><BR>


EOF
    ;
    }
    if (! ($form{'Type'} eq 'error')) {
	print <<EOF;
<p><FORM ACTION="AT-generate$script_suffix" METHOD=POST>
<INPUT TYPE="hidden" NAME="db" VALUE="$form{'db'}">
<INPUT TYPE="submit" NAME="Errors" VALUE="Errors">
Show the contents of the error log file.
<INPUT TYPE="hidden" NAME="Dump" VALUE="dummy">
<INPUT TYPE="hidden" NAME="File" VALUE="$filestub.err">
<INPUT TYPE="hidden" NAME="Type" VALUE="error">
$postpass
</FORM><BR>


EOF
    ;
    }
    print <<EOF;
<p><FORM ACTION="AT-admin$script_suffix" METHOD=POST>
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

if ($form{'Status'}) {
	&Architext'printHeader($attr{'ArchitextURL'}, 
			       "View Indexing Logfiles: $form{'db'}");
	print "<p> This page provides access to the three log files that the indexing process creates.  \n";
	print "<hr><b>Collection Status</b><ul>\n";
	&Architext'printStatus($form{'db'}, $root, $attr{'ConfigRoot'},
			       $attr{'ArchitextURL'}, $helppath,
			       $attr{'CollectionRoot'},
			       $attr{'CgiBin'});
	print "</ul>\n";
	$logname = "AT-$form{'db'}.log";
	$progname = "AT-$form{'db'}.prog";
	$errname = "AT-$form{'db'}.err";
	$urlpath = "$root/collections";
    
print <<EOF;
<p><hr>
<b>Logfiles:</b>
<p>
<FORM ACTION="AT-generate$script_suffix" METHOD="POST">
<INPUT TYPE="hidden" NAME="Dump" VALUE="dummy">
<INPUT TYPE="hidden" NAME="db" VALUE="$form{'db'}">
<INPUT TYPE="hidden" NAME="Type" VALUE="progress">
<INPUT TYPE="hidden" NAME="File" VALUE="$urlpath/$progname">
<INPUT TYPE="submit" VALUE="Progress"> Show the progress of the indexing 
process.
$postpass
</FORM>
<p>
<FORM ACTION="AT-generate$script_suffix" METHOD="POST">
<INPUT TYPE="hidden" NAME="Type" VALUE="verbose">
<INPUT TYPE="hidden" NAME="db" VALUE="$form{'db'}">
<INPUT TYPE="hidden" NAME="Dump" VALUE="dummy">
<INPUT TYPE="hidden" NAME="File" VALUE="$urlpath/$logname">
<INPUT TYPE="submit" VALUE="Verbose log"> Show a detailed log of
the indexing process.
$postpass
</FORM>
<p>
<FORM ACTION="AT-generate$script_suffix" METHOD="POST">
<INPUT TYPE="hidden" NAME="Type" VALUE="error">
<INPUT TYPE="hidden" NAME="db" VALUE="$form{'db'}">
<INPUT TYPE="hidden" NAME="Dump" VALUE="dummy">
<INPUT TYPE="hidden" NAME="File" VALUE="$urlpath/$errname">
<INPUT TYPE="submit" VALUE="Errors"> Show any errors that might
have occured during indexing.
$postpass
</FORM>
<hr>
<b>Possible Actions:</b>
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

if ($form{'Generate'}) {
    if ($form{'qtemplate'}) {
	if ((! -e $form{'qtemplate'}) || (! -r $form{'qtemplate'})) {
	    $tmessage = "<b> The template file you specified, '$form{'qtemplate'}', is not readable or does not exist. Please try again.</b>";
	    $form{'qpage'} = "";
	}
    }
    if ($form{'ExciteButton'} && ($form{'bltext'} && (! $form{'backlink'}))) {
	$tmessage = "<b> If you provide linktext, you must provide a backlink URL as well.</b>";
	$form{'qpage'} = "";
    }
    if ($form{'ExciteButton'} && ((! $form{'bltext'}) && $form{'backlink'})) {
	$tmessage = "<b> If you provide a backlink URL, you must also provide linktext.</b>";
	$form{'qpage'} = "";
    }
    if (length($form{'bltext'}) > 20) {
	$tmessage = "<b>Please limit the linktext to 20 characters or fewer.</b>";
	$form{'qpage'} = "";
    }
    if ($form{'rtemplate'}) {
	if ((! -e $form{'rtemplate'}) || (! -r $form{'rtemplate'})) {
	    $tmessage = "<b> The template file you specified, '$form{'rtemplate'}', is not readable or does not exist. Please try again.</b>";
	    $form{'qpage'} = "";
	}
    }
    if (! -d "$form{'unprefix'}") {
	$tmessage = "<b> The path prefix you specified, '$form{'unprefix'}' does not exist, or is not a directory.  Please try again.</b>";
	$form{'qpage'} = "";
    }
    if ($form{'qpage'} && $form{'unprefix'}) {
	## Assuming all the relevant configuration options are specified
	## as form arguments, this mode generates the pages.
	## also checks for required elements 

	## Header again
	&Architext'printHeader($attr{'ArchitextURL'}, 
			       "Search Page Generation: $form{'dbname'}");

	if (!$form{'dbname'}) { 
	    &Architext'exitError($attr{'ArchitextURL'},
				 "Index specified with no dbname."); }

	## Can we read the db.conf file?
	$dbconfig = $root . "/collections/" . $form{'dbname'} . ".conf";
	if (-e $dbconfig && ! -r $dbconfig) {
	    &Architext'exitFileError($attr{'ArchitextURL'},
				     $dbconfig, 
				     "does not exist or is not readable."); }
    
	## create the default html pages here.
	## on the query.html page to produce the search$script_suffix script
	&simpleQueryPage();
	&simpleSearchScript();
	
	$simplepage = $form{'qpage'};
	$simplepage .= ".html" unless $simplepage =~ /\.html$/;
	
	## set up proper arguments for moving scripts to cgi-bin
	$form{'qname'} = $simplepage;
	$form{'qscript'} = "AT-$form{'dbname'}search$script_suffix";
        $files = "<b>$form{'qscript'}</b>";

	if ($form{'Move'}) {
	    $exit = &copy_search_file("$root/$form{'qscript'}", 
				      $attr{'CgiBin'}, $root, $form{'dbname'})
		unless ($root eq $attr{'CgiBin'}); 
	    if (! $exit) {
	    ## Let the user know the generation was successful.
            print "<H2>Generation successful.</H2>\n";
	    print "<p>\n";	
            &remove_files("$root/$form{'qscript'}") unless
		(($root eq $attr{'CgiBin'}) || (&os_name() =~ /NT/));
	    ## print "<h2> Moving successful. </h2>\n<p>";

	    print <<EOF;
Your <b>cgi</b> scripts ($files)
have been generated and installed in your
<b>cgi-bin</b> directory, <b>$attr{'CgiBin'}</b>.
EOF
;

if (-e "$root/collections/$form{'dbname'}.last") {
print <<EOF;
<p>Since you have already created your indexes for this document collection, 
you can now 
<A HREF="$attr{'ArchitextURL'}$form{'qname'}">
<b>Start Searching!</b></a>
EOF
;
}
print <<EOF;
<p> Once you have tested <b>$form{'qname'}</b> to your liking, 
feel free to move it from the Excite administration directory
(<b>$attr{'ConfigRoot'}</b>) into a directory better suited to 
your needs.
EOF
    ;
} else {
    $warn = &Architext'errorIcon($attr{'ArchitextURL'});
print <<EOF;
<h2>${warn}Problem moving '$files' from 
$root to $attr{'CgiBin'} -- $!</h2>

<p>Your scripts have been generated, but they were not copied
into your <b>cgi-bin</b> (<b>$attr{'CgiBin'}</b>) directory because
an error was encountered (probably a permissions problem)
while moving the files. <p>$warn<b>IMPORTANT:</b> Before you can do queries, 
you will either need to move the script that
was just generated ($files) from <b>$root</b> 
into <b>$attr{'CgiBin'}</b>, or
you can try to <b>Generate</b> the scripts again after investigating
the problem.
EOF
    ;
}
} else {
    $warn = &Architext'errorIcon($attr{'ArchitextURL'});
    ## user's cgi-bin was not writeable, so we won't try to move 
    ## the scripts there
    print <<EOF;

<h2> ${warn}Scripts generated, but not moved. </h2>
<p> Your scripts have been generated, but were not copied into your
cgi-bin directory (<b>$attr{'CgiBin'}</b>), because it
is not writeable by the userid your Web server is running under.
<p>$warn<b>IMPORTANT: Before you can being making queries, you must copy the 
CGI scripts that were generated into your cgi-bin directory.</b>

<p> Copy $files from the directory
<b>$root</b> to the cgi-bin directory, and you
can begin making queries.

EOF
    ;
}
 
print <<EOF;
<p> <b>SECURITY ISSUE:</b>  Remember that by making the query page available
to users of your Web site, you are giving them easy access to all
the pages on your site that have been indexed.  If you have sensitive
information that you do not wish to be available to every user of
your Web site, consider leaving those files out of your indexes, or
consider making the search page secure in order to restrict access to it.
<hr><b>Possible Actions:</b>
EOF
    ;
if (! ((-e "$root/collections/$form{'dbname'}.last") ||
       (-e "$root/collections/$form{'dbname'}.pid") ||
       (-e "$root/collections/new/$form{'dbname'}.err")))
{			       
    print <<EOF;
<p> <FORM ACTION="AT-index$script_suffix" METHOD=POST>
<INPUT TYPE="submit" NAME="Indexing" VALUE="Index">
Create an index for this collection.
<INPUT TYPE="hidden" NAME="db" VALUE="$form{'dbname'}">
$postpass
</FORM><BR>
EOF
    ;
}

if ((-e "$root/collections/$form{'dbname'}.pid") 
    || (-e "$root/collections/$form{'dbname'}.last")
    || (-e "$root/collections/new/$form{'dbname'}.err" )) {
print <<EOF;
<p> <FORM ACTION="AT-generate$script_suffix" METHOD=POST>
<INPUT TYPE="submit" NAME="Status" VALUE="Status">
Check the status of indexing on this collection.
<INPUT TYPE="hidden" NAME="db" VALUE="$form{'dbname'}">
$postpass
</FORM><BR>

EOF
    ;
}
    print <<EOF;
<p> 
<FORM ACTION="AT-admin$script_suffix" METHOD=POST>
<INPUT TYPE="submit" NAME="Admin" VALUE="Admin">
<INPUT TYPE="hidden" NAME="db" VALUE="$form{'dbname'}">
Go back to the admin page for this collection.
$postpass
</FORM><BR>

EOF
    ;				
	&Architext'Copyright($attr{'ArchitextURL'});
	exit(0);
    } else {
	## required elements were not passed in.
	$message = "<b>You didn't enter a value for a required field.  Please try again.</b>";
$message = $tmessage if $tmessage;
	$form{'db'} = $form{'dbname'};
    }
} 
if ($form{'db'}) {
    ## Print out configuration options for an already-existing
    ## database so the user knows what will happen upon page generation

    ## Dump our standard header
    &Architext'printHeader($attr{'ArchitextURL'},
			   "Search Page Generation: $form{'db'}");

    ## Check for the desired database.conf file.
    $dbconfig = $root . "/collections/" . $form{'db'} . ".conf";
    if (! -r $dbconfig) { 
	&Architext'exitFileError($attr{'ArchitextURL'},
				 $dbconfig, "does not exist"); }

    ## Read all the configuration information.
    ## %attr = &ArchitextConf'readConfig("$root/Architext.conf", $form{'db'});

    ## advise the user if required fields were not passed in
    $warn = &Architext'errorIcon($attr{'ArchitextURL'}); 
    print "$warn$message" if $message;

    print "<p> The collection you have chosen has ";
    print "the following characteristics:\n";
    ## Print the form.
    ## This form is just a little list of the options.
    &Architext'collectionCharacteristics($form{'db'}, $helppath, %attr); 
    &printForm($form{'db'});
    if ($getpass) {
	$getpass .= "&";
    } else {
	$getpass = "?";		
    }
    $getpass .= "db=$form{'db'}";
    &Architext'Copyright($attr{'ArchitextURL'});
    exit(0);

} else {
    ## Print out the top-level screen: scan the root directory for
    ## db.conf files, and allow the user to initialize a new db.conf
    ## file.

    opendir(CONF, "$root/collections");
    @dbconf = grep(/\.conf$/, readdir(CONF));

    &Architext'printHeader($attr{'ArchitextURL'},"Search Page Generation");
    if ($#dbconf > -1) {
    print <<EOF;
<FORM ACTION="AT-generate$script_suffix" METHOD=POST>
Choose a document collection for which to generate query and result pages.<P>
<DL>
<DT> 
Existing <a href="${helppath}AT-helpdoc.html#Document Collections">document collections:</a> <DD>
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
<INPUT TYPE="submit" NAME="select" VALUE="Select">
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

## Prints an input line for a form.
sub printLineItem {
    local($name, $text) = @_;
    local($val);
    $text = $name unless $text;
    $val = eval "\$attr{$name}";
    print qq(<li> <a href="${helppath}AT-helpdoc.html#$text">$text:</a> $val\n);
}

## Prints out the Architext form. Uses dynamic scoping to ensure that
## the values in the %attr array are properly set.
sub printForm {
    local($db) = shift;
    local ($size) = 30;
    print qq(<FORM ACTION="AT-generate$script_suffix" METHOD=POST>\n);
    if (($attr{'CgiBin'}) && (-w "$attr{'CgiBin'}")) {
	print qq(<INPUT TYPE="hidden" NAME="Move" VALUE="yes">\n);
    }
    $pprefix = $form{'unprefix'} ||
	$attr{'HtmlRoot'};
    $qimage = $form{'qimage'} || 
	"$attr{'ArchitextURL'}pictures/$query_banner";
    $size = (length($pprefix)+10) 
	unless ((length($attr{'HtmlRoot'})+10) < 30);
    $qlength = (length($qimage) + 10); 
    print <<EOF;
<INPUT TYPE="hidden" NAME="qpage" VALUE="AT-$form{'db'}query.html">
<INPUT TYPE="hidden" NAME="unprefix" VALUE="$pprefix">
<p> <b>Optional Information</b><ul>
<p> Enter <a href="${helppath}AT-helpdoc.html#Banner Image">
Banner Image</a> to appear at the top of query and result pages:
<INPUT NAME="qimage" VALUE="$qimage"
SIZE=$qlength>
<p>Enter a <a href="${helppath}AT-helpdoc.html#Brief Description">
brief description</a>
 of the contents of your database for use in 
the query page.  The generated query page will appear in 
<b>$attr{'ConfigRoot'}</b>. 
<TEXTAREA NAME="describe" COLS=60 ROWS=4>$form{'describe'}</TEXTAREA>
<p><INPUT TYPE="checkbox" NAME="ExciteButton" VALUE="ExciteButton" CHECKED>
Allow internet-wide searches on <a href="http://www.excite.com">excite</a> on the generated search page.
EOF
    ;
    if (&Architext'backlinkMode()) {
	$blval = $form{'backlink'} || 
	    "http://$ENV{'SERVER_NAME'}:$ENV{'SERVER_PORT'}$attr{'ArchitextURL'}AT-$form{'db'}query.html";
	$blsize = length($blval);
	print <<EOF;
<br>If you would like internet-wide excite searches to provide a link
back to your site, fill in the blanks below:
<ul>
Optional <a href="${helppath}AT-helpdoc.html#Backlink">Backlink:</a>
<INPUT NAME="backlink" VALUE="$blval" SIZE=$blsize><br> 
Optional <a href="${helppath}AT-helpdoc.html#Linktext">Linktext:</a>
<INPUT NAME="bltext" VALUE="$form{'bltext'}" SIZE=30><br>
</ul>
EOF
    ;
    }
    print <<EOF;
</ul>
<b> Advanced Customization Information </b>
<ul>
<p> Enter the name of a <a href="${helppath}AT-helpdoc.html#Query Template">
query template</a> file:
<INPUT NAME="qtemplate" VALUE="$form{'qtemplate'}" SIZE=40>
<p> Enter the name of a <a href="${helppath}AT-helpdoc.html#Query-Results Template">
query-results template</a> file:
<INPUT NAME="rtemplate" VALUE="$form{'rtemplate'}" SIZE=40>
</ul><hr>
<b> Possible Actions:</b>
<p><INPUT TYPE="submit" NAME="generate" VALUE="Generate">
Generate the query pages and scripts need to perform queries.
<INPUT TYPE="hidden" NAME="Generate" VALUE="Generate">
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

## creates the script that actually performs the searches
sub simpleSearchScript {
    local($scriptname, $preflag, $postflag);
    local($umapfile, %mappings);
    $preflag = $postflag = 0;
    
    $scriptname = "$root/AT-$form{'dbname'}search$script_suffix";
    &remove_files($scriptname);
    open(SCRIPT, ">$scriptname") 
	|| &Architext'exitError($attr{'ArchitextURL'},
				"Could not open '$scriptname' for writing");
    ## standard header information
    if (&non_shell_invocation_ok($attr{'PerlRoot'})) {
	print SCRIPT "#!$attr{'PerlRoot'}\n\n";
    } else {
	print SCRIPT "#!/bin/sh\n";
	$aproot = $attr{'PerlRoot'};
	$aproot =~ s/\\/\\\\/g;
	print SCRIPT "perl=$aproot\n";
	print SCRIPT "eval \"exec \$perl -x \$0 \$*\"\n";
	print SCRIPT "#!perl\n\n";
    }
    $aroot = $root;
    $aroot =~ s/\\/\\\\/g;
    print SCRIPT "\$root = \"$aroot\";\n";
    print SCRIPT "unshift(\@INC, \"\$root/perllib\");\n";
    print SCRIPT "require 'architext_query.pl';\n";
    print SCRIPT "require 'ctime.pl';\n";
    ## insert db specific information here
    print SCRIPT "\$aurl = \"$attr{'ArchitextURL'}\";\n";
    print SCRIPT "\$db = \"$form{'dbname'}\";\n";
$acroot = $attr{'CollectionRoot'};
    $acroot =~ s/\\/\\\\/g;
    print SCRIPT "\$index = \"$acroot\";\n";
    $ahroot = $attr{'HtmlRoot'};
    $ahroot =~ s/\\/\\\\/g;
    print SCRIPT "\$hroot = \"$ahroot\";\n";
    $aexec = $attr{'SearchExecutable'};
    $aexec =~ s/\\/\\\\/g;
    print SCRIPT "\$binary = \"$aexec\";\n";
    ##create the url edit option here by getting all the mappings
    $umapfile = "$root/collections/$form{'dbname'}.usr" 
	if ($attr{'PublicHtml'});
    %mappings = 
	&ArchitextMap'getMappings($attr{'HtmlRoot'},
			       "$root/url.map",
			       $umapfile);
    $urledit = &ArchitextMap'generateURLEdit(%mappings);
    print SCRIPT "\$urledit = '$urledit';\n\n";

    $log_file = ", '$root/query.log'" if &Architext'logMode();

    print SCRIPT "\%form = &ArchitextQuery'readFormArgs;\n";
    print SCRIPT 
	"&ArchitextQuery'directQuery(\$form{'search'} || '(no search)',\n";
    print SCRIPT "\t\$form{'mode'} || 'concept', \$db, \$form{'source'} || 'local', \$form{'backlink'} || '*', \$form{'bltext'} || '*'$log_file);\n";
    print SCRIPT "print \"Content-type: text/html\\n\\n\";\n";

    ## insert standard template code
    open(TEMPLATE, "$root/AT-template.cgi") 
	|| &Architext'exitError($attr{'ArchitextURL'},
				"Could not open '$root/AT-template.cgi'");

    while ($tmpstr = <TEMPLATE>) {
        last if ($tmpstr =~ /^___SEPARATOR___/);
	print SCRIPT $tmpstr;
    }

    if ($form{'rtemplate'}) {
	## using template file
	open(TFILE, "$form{'rtemplate'}") 
	    || &Architext'exitError($attr{'ArchitextURL'},
				    "Couldn't open '$form{'rtemplate'}'");
	print SCRIPT "print <<EOF;\n";
	while (<TFILE>) {
	    $preflag = 1 if /\#\#\#EXCITE\#\#\#/;
	    s/\@/\\\@/g;
	    print SCRIPT unless $preflag;
	}
	close(TFILE);
	print SCRIPT "\nEOF\n;\n";
    } else {
	##using 'stock' script
	print SCRIPT "print \"<html><head><title>Excite for Web Servers Search Results</title></head>\\n\";\n"; 
	print SCRIPT "print \"<body BGCOLOR=\\\"#FFFFFF\\\" TEXT=\\\"#000000\\\" LINK=\\\"#FF0000\\\" ALINK=\\\"#0000FF\\\">\";\n";
	$query_banner = &Architext'queryBanner();
	if ($form{'qimage'} =~ $query_banner) {
	    $pre_anchor = "<a href=\\\"http://www.excite.com/\\\">";
	    $post_anchor = "</a>";
	}
	print SCRIPT "print \"<h1>$pre_anchor<img src=\\\"$form{'qimage'}\\\" BORDER=0>$post_anchor</h1>\\n\";\n";
    }
    
    while (<TEMPLATE>) {
	print SCRIPT $_;
    }

    if ($form{'rtemplate'}) {
	open(TFILE, "$form{'rtemplate'}") 
	    || &Architext'exitError($attr{'ArchitextURL'},
				    "Could not open '$form{'rtemplate'}");
	while (<TFILE>) {
	    s/\@/\\\@/g;	
	    print SCRIPT if $postflag;
	    if (/\#\#\#EXCITE\#\#\#/) {
		$postflag = 1;
		print SCRIPT "print <<EOF;\n";
	    }
	}
	close(TFILE);
	print SCRIPT "\nEOF\n;\n";
    } else {
	print SCRIPT "print \"</body></html>\\n\";\n";
    }

    close(SCRIPT);
    close(TEMPLATE);
    $exit = &make_file_executable($scriptname);
    &Architext'exitError($attr{'ArchitextURL'}, 
			 "Can't change permissions on '$scriptname' - $!")
	if $exit;

}

## prints a default query page with a simple description
sub simpleQueryPage {
    local($simplepage);
    local($exit);
    $simplepage = $form{'qpage'};
    $simplepage .= ".html" unless $simplepage =~ /\.html$/;
    $simplepage = $root . "/" . $simplepage;
    &remove_files($simplepage); 
    open(SPAGE, ">$simplepage") ||
	&Architext'exitFileError($attr{'ArchitextURL'},
				 $simplepage, 
				 "could not be opened for writing.");
    if ($form{'qtemplate'}) {
	##user is using template file
	open(TEMPLATE, "$form{'qtemplate'}") ||
	    &Architext'exitFileError($attr{'ArchitextURL'},
				     $form{'qtemplate'}, 
				     "could not be opened for reading.");
	while (<TEMPLATE>) {
	    if (/\#\#\#EXCITE\#\#\#/) {
		&printQueryForm();
	    } else {
		print SPAGE $_;
	    }
	}
	close(TEMPLATE);
    } else {

	print SPAGE "<html><head><title>Excite Searching</title></head>\n";
	$query_banner = &Architext'queryBanner();
	if ($form{'qimage'} =~ $query_banner) {
	    $pre_anchor = "<a href=\"http://www.excite.com/\">";
	    $post_anchor = "</a>";
	}
	print SPAGE qq(<body BGCOLOR="#FFFFFF" TEXT="#000000" LINK="#FF0000" ALINK="#0000FF">\n);
	print SPAGE qq(<h1>$pre_anchor<img src="$form{'qimage'}" BORDER=0>$post_anchor</h1>\n) 
	    if $form{'qimage'};

	$describeit = $form{'describe'};
	print SPAGE "<p><b>Database description:</b> $describeit \n<p>\n"
	    if $describeit;
	&printQueryForm();
	print SPAGE "\n</body></html>\n";
    }
    close(SPAGE);
    ## don't copy files if config root and architext root are the same
    if ($root ne $attr{'ConfigRoot'}) {
	$exit = &copy_files($simplepage, $attr{'ConfigRoot'});
	&Architext'exitError($attr{'ArchitextURL'},
			     "Cannot copy $simplepage to $attr{'ConfigRoot'}") if $exit;
    }
}

## prints the query form onto the querypage (SPAGE)
sub printQueryForm {
    local($skip_radio);
    local($query_help) = "$attr{'ArchitextURL'}AT-queryhelp.html";
    local($cgi) = $ENV{'SCRIPT_NAME'};
    $cgi =~ s/\/?[^\/]+$//;
    local($excite_button) = &Architext'searchButton();
    local($excited_ad) = &Architext'excitedAd();
    $excite_button = "$attr{'ArchitextURL'}pictures/$excite_button";
    local($excited_label) = "$attr{'ArchitextURL'}pictures/$excited_ad";
    local($search_script) = "$cgi/AT-$form{'dbname'}search$script_suffix";
    open(QFORM, "$root/AT-query.html") ||
	&Architext'exitFileError($attr{'ArchitextURL'},
				 "$root/AT-query.html", 
				 "could not be opened for reading.");
    while (<QFORM>) {
	s/CGI/$search_script/;
	s/BUTTON/$excite_button/;
	s/DOC/$query_help/;
	s/BACKLINK/$form{'backlink'}/;
	s/LINKTEXT/$form{'bltext'}/;
	s/EXCITED/$excited_label/;
	s/QUERY//;
	print SPAGE "$_\n" unless ((/___SEPARATOR___/) || $skip_radio ||
				   (/___END___/));
	$skip_radio = 0 if (/___END___/);
	$skip_radio = 1 if ((/___SEPARATOR___/) && (! $form{'ExciteButton'})); 
    }
    close(QFORM);
}

## returns true if OS can handle #! lines > 32 chars
sub non_shell_invocation_ok {
    local($perlpath) = @_;
    local($os) = &os_name();
    return 0 if ($os eq 'NT');
    return 1 if (($os =~ /BSD/) || ($os =~ /IRIX/)  ||
		 ($os =~ /AIX/) || (($os =~ /SunOS/) && (! -e '/vmunix')));
    return 1 if ( length($perlpath) < 30); 
    return 0;			
}
