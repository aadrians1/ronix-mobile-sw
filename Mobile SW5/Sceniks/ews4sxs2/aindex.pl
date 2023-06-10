#!/bin/sh
perl=/usr/local/www/scenix.com/ews4sxs2/perl
eval "exec $perl -x $0 $*"
#!perl

## Copyright (c) 1996 Excite, Inc.
##
## This program is a flexible wrapper for the index program. For
## maximum efficiency, you might want to invoke the executable
## directly, pointing it to the proper info file with "-C".

## this script will index a collection in a 'safe' directory
## and then move the finished index files in to the specified
## destination location once indexing completes successfully.
## This script will also mail a specified user when indexing completes
## if a email address is given in the collections configuration file

BEGIN {
  $root = "/usr/local/www/scenix.com/ews4sxs2";
  $ENV{"LD_LIBRARY_PATH"} = ($ENV{"LD_LIBRARY_PATH"} ?
			     ($ENV{"LD_LIBRARY_PATH"}.":") : "").$root;
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

$ENV{'PATH'} = '/bin:/usr/bin';


require 'os_functions.pl';		       
require 'architextConf.pl';
require 'architextNotify.pl';
require 'architext_query.pl';
require 'architext_map.pl';
require 'ctime.pl';


$database = shift;
if (! $database) {
    $error = "Must specify database" unless $database;
    goto DONE;
}

$logfile = shift;
$progfile = shift;
$errfile = shift;

## create an empty .inv file so that index forms can tell that
## aindex.pl was actually invoked
open(TEMP, ">$root/collections/$database.inv");
close(TEMP);

## the following code seeds the log files appropriately
$|=1;
if ($errfile) {
    unlink($errfile);
    open(ERRS, ">$errfile");
    print ERRS "No errors encountered so far...\n";
    close(ERRS);
}
if ($logfile) {
    unlink($logfile);
    open(LOG, ">$logfile");
    print LOG "Nothing yet logged to this file.  Check error log for problems.\n";
    close(LOG);
}
if ($progfile) {
    unlink($progfile);
    open(PROG, ">$progfile");
    print PROG "Nothing yet logged to this file.  Check error log for problems.\n";
    close(PROG);
}


$logfileopt = "-log $logfile" if $logfile;
$progfileopt = "-prog $progfile" if $progfile;

## Read the configuration file and look for the database.
%attr = &ArchitextConf'readConfig("$root/Architext.conf", $database);

if (! $attr{'CollectionInfo'}) {
    $error =  "Configuration file must specify CollectionInfo file\n";
    goto DONE;
}


##ECO -- improvements to indexing rules 
$filter = $attr{'IndexFilter'}; ## check for html only indexing
$filterflag = " ";
$filterflag = "-html" if ($filter =~ /HTML/);
$filterflag .= " -text" if ($filter =~ /TEXT/);
$filterflag .= " -pdf" if ($filter =~ /PDF/);
if ($filter =~ /CUST/) {
    $clusionfile = "$root/collections/$database.excl";
    unlink($clusionfile);
    &compileExcludeFile($attr{'ExclusionRules'}, $clusionfile);
    goto DONE if $error;
}
$filterflag .= " -excl $clusionfile" if ($filter =~ /CUST/);


$mailid = $attr{'AdminMail'};  ## check for user to alert when finished

## ECO keep back compatibility with old .conf files
if ($filter =~ /Text/) {
    $filterflag = "-html -text" ;
    $filterflag .= " -excl $attr{'ExclusionRules'}" if $attr{'ExclusionRules'};
} 

chop($startTime = &ctime(time));

## Possibly create a CollectionInfo file.
if (! -e $attr{'CollectionInfo'}) {
    print STDERR "Creating CollectionInfo file '$attr{'CollectionInfo'}'\n";
    $attr{'PidFile'} = "$root/collections/$database.pid";
    $attr{'NS'} = 1 if &ArchitextQuery'NSOn();
    &ArchitextConf'makeInfoFile(%attr);
    if (! -e $attr{'CollectionInfo'}) {
	$error = "Failed to create CollectionInfo file";
	goto DONE;
    }
}



## calculate $newroot here to do indexing in a 'safe' directory to
## keep index as available as possible
$newroot = $attr{'CollectionRoot'};
$newroot =~ /[\\\/]?([^\/\\]+)$/;
$rootstub = $1;
$newrootdir = $attr{'CollectionIndex'};
$attr{'CollectionIndex'} .= "/" unless ($attr{'CollectionIndex'} =~ /[\/\\]$/);
$newroot = "$attr{'CollectionIndex'}new/$rootstub";
$chmodfiles = "$newroot*";
$cpfiles = "$newroot*";
$cpdest = "$newrootdir";
$rmfiles =  "$newroot*";
$newroot = "-R $newroot";

## create 'new' subdirectory for indexing
if (! -e "$attr{'CollectionIndex'}new") {
    $exit = &make_directory("$attr{'CollectionIndex'}new");
    $error = "Can't mkdir $attr{'CollectionIndex'}new -- $!" if $exit;
    goto DONE if $exit;
}

if (-e "$root/collections/$database.cus") {
    &copy_files("$root/collections/$database.cus", 
		"$attr{'CollectionIndex'}/new");
}

## remove error flag from any previous indexing runs
unlink("$root/collections/$database.err");

if (! $attr{'IndexExecutable'}) {
    $error = "Configuration file must specify IndexExecutable\n";
    goto DONE;
}


$indexer = &ArchitextConf'makeAbsolutePath($attr{'IndexExecutable'},
					   $attr{'ArchitextRoot'});


if (! &executable($indexer)) {
    $error =  "IndexExecutable '$indexer' does not exist or is not really exectuable\n";
    goto DONE;
}


## tell indexer which files to index
## Will pass exclusion argument to executable as well.

$output_file = "$root/collections/$database.out";
unlink($output_file);
@inputs = &splitFileList($attr{'CollectionContents'});
$index = join(" ", @inputs);
$index = " " . $index;
$indexbegin = 1;
if ($index =~ /\s\+/) { 
    ## this is the filelist case in the old versions
    $index = "";
    $flist =~ s/\+//g;
    $flist = "-flist $flist";
} 
$flist = "-flist $attr{'FileList'}" if $attr{'FileList'};
$ulist = "-ulist $root/collections/$database.usr2" if $attr{'PublicHtml'};



## new addition for calculation of inline summaries
$summary_flag = "-qsum" if ($attr{'SummaryMode'} eq 'quality');
$summary_flag = "-fsum" unless $summary_flag;
$nss = "-nss $attr{'NumSumSent'}" if $attr{'NumSumSent'};
$s_d = "-spider $attr{'SpiderDir'}" if $attr{'SpiderDir'};
$sroot = "-sroot $root/collections/summary/sum$$";
$mapping = "-mapfile $root/url.map" if ((&ArchitextQuery'indexTimeMapping()) 
					&& (-e "$root/url.map"));
$comments = "-comments" if (&ArchitextQuery'indexHtmlComments());

$index_command = "$indexer -C $attr{'CollectionInfo'} $newroot $logfileopt $progfileopt $flist $ulist $mapping $comments $filterflag $s_d $nss $summary_flag $sroot $index > $output_file";
$index_command = &convert_file_names($index_command); 
$exit = system($index_command);  

open(INDEX, $output_file);
##capture errors from index subprocess
while ($errline = <INDEX>) {
    next unless ($errline =~ /^ARCHITEXTERROR:/);
    $errline =~ s/^ARCHITEXTERROR://;
    unshift(@errs, $errline);
}

close(INDEX);
unlink($output_file);

## check for error output or error exit status from indexer
if (($#errs > -1) || $exit) {
    $errorflag = 1;
    $error = $! if $exit;
}

&remove_files("$attr{'CollectionIndex'}new/$database*tmp*");

if (-e "$root/collections/$database.term") {
    $error = "Indexing process was terminated by the administrator.";
    $terminated = 1;
    unlink("$root/collections/$database.term");
}

if ($terminated || $error || $errorflag) {
    chop($endTime = &ctime(time));
    goto DONE;
}

## sanity check
if (! -e "$attr{'CollectionIndex'}new/$database.dat") {
    $error = "Indexing error -- no .dat file found." ;
    chop($endTime = &ctime(time));
    goto DONE;
}

## make the index files readwriteable by all to avoid problems
$exit = &make_files_readwriteable($chmodfiles) unless ($error || $errorflag);
## move the now successfully built index files to the official location
$exit = &copy_files($cpfiles, $cpdest) unless ($error || $errorflag);
$error = "Error copying index files from temporary build location\nto new locations: $!" if $exit;
$exit = 0;
## is this a fatal error?
$exit = &remove_files($rmfiles) unless ($error || $errorflag);
$error = "Error removing index files from temporary build location\nto new location (this is a non-fatal error.): $!" if $exit;

if ($error) {
    chop($endTime = &ctime(time));
    goto DONE;
}

## indexing is complete - record time of completion, size of index
chop($endTime = &ctime(time));
unlink("$root/collections/$database.err");
open(LAST, ">$root/collections/$database.last");
print LAST "$endTime";
close(LAST);

## create files for notifier and perform notification if notifier-enabled
if (&ArchitextQuery'notifyMode()) {
    $notifybegin = 1;
    $notifier_enabled = (-e "$root/collections/$database.pub");
}
if (!$notifier_enabled) {
    goto DONE;
}

## create url/title files and summary files
open(PROG, ">>$progfile") if ($progfile);
open(LOG, ">>$logfile") if ($logfile);
print PROG "building auxiliary files for notifier...\n" if $progfile;
print LOG "building auxiliary files for notifier...\n" if $logfile;
close(LOG);
close(PROG);

$status = &ArchitextQuery'createURLFiles($root, $database, %attr);
if ($status == -1) {
    $error = "building auxiliary files for notifier failed.  This error is non-fatal, but excite will not be notified of index changes";
    goto DONE;
}
$create_command = "$root/architextIndex -sumfile -R $attr{'CollectionRoot'}";
$create_command = &convert_file_names($create_command);
$status = system($create_command);
if ($status) {
    $error = "building auxiliary files for notifier failed.  This error is non-fatal, but excite will not be notified of index changes";
    goto DONE;
}
 
## perform the notification
open(PROG, ">>$progfile") if $progfile;
open(LOG, ">>$logfile") if $logfile;
print PROG "notifying excite...\n" if $progfile;
print LOG "notifying excite...\n" if $logfile;
$status = &ArchitextNotify'notify($database);
if ($status == 0) {
    $error = "couldn't notify excite.  This is a non-fatal error, but excite will not be notified of index changes";
}
else {
    print PROG "Excite notification done.\n";
    print LOG "Excite notification done.\n"; 
}
close(LOG);
close(PROG);

DONE:

## set the flag if there was an error but the flag wasn't set
$errorflag = 1 if ($error && !$errorflag);

## there was an error
if ($errorflag) {
    open(PROB, ">$root/collections/$database.err") unless $terminated;
    close(PROB) unless $terminated;
}

## Use Messenger service in NT to alert user when indexing is done
if (($ews_port eq 'NT') && $mailid) {
    $special_message = "Excite indexing process on collection $database ";
    $special_message .= "finished successfully."
	unless $errorflag;
    $special_message .= "was terminated."
	if $terminated;
    $special_message .= 
	"failed due to an error.  Please check logs for details."
	    if ((! $terminated) && ($errorflag));
    system("net send $mailid $special_message");
    $mailid = "";
}


## Mail user if required
if ($mailid) {
    $mailapp = &mailer($root);
    open(MAIL, "| $mailapp $mailid");
    print MAIL "To: $mailid\n";
    ## if there is an error, determine at what stage it occurred
  ERRORTYPE: {
      if (!$errorflag) { last ERRORTYPE; }
      if (!$indexbegin) { $notInvoked=1; last ERRORTYPE; }
      if (!$notifybegin || $terminated) { $indexerror=1; last ERRORTYPE; }
      $notifyerror = 1;
  }
    
    if (!$errorflag) {
	print MAIL "Subject: Excite indexing process finished.\n";
    }
    elsif ($terminated) {
	print MAIL "Subject: Excite indexing process terminated.\n";
    }
    elsif ($notInvoked || $indexerror) {
	print MAIL "Subject: Error in Excite indexing process.\n";
    }
    else {
	print MAIL "Subject: Error in Excite notification process.\n";
    }
    if ($notInvoked) {
        print MAIL "\nYour indexing process was never invoked because of the following:\n\n$error\n";
    }
    else {
        print MAIL "\nYour indexing process invoked at $startTime\n";
	print MAIL "for the collection '$database' has finished at $endTime.\n";
	print MAIL "\nIndexing was successful.\n" unless ($indexerror);
        print MAIL "\nIndexing was unsuccessful because of the following:\n\n$error\n" if ($indexerror);

        print MAIL "\nNotification was unsuccessful because of the following:\n\n$error\n" if ($notifyerror);
    }
}

## Report any errors to mail, stdout, and error log
open(ERRLOG, ">$errfile") if $errfile;
if ($errorflag) {
    while ($errline = pop(@errs)) {
	print MAIL $errline;  ##report to mail
	print ERRLOG $errline if $errfile; ##report to error log
	print $errline; ##report to stdout
    }
    ## this has already been sent to mail
    ##print MAIL "\n$error\n";
    print ERRLOG "\n$error\n";
    print "\n$error\n";
}

## add message about running out of vmem on NT
if (($ews_port eq 'NT') && ($errorflag || $error)) {
    print ERRLOG "\n\nNOTE: If a message box appeared on the server machine indicating that the\nsystem was 'Low on Virtual Memory' or 'Out of Virtual Memory', the indexing\nprocess may have died due to insufficient resources.  Try shutting down other\napplications or increasing the size of your swap file, and then invoke the\nindexing process again.\n";
}


print MAIL "\nThank You,\nThe Excite Indexer\n" if $mailid;
close(MAIL) if $mailid;
if ($errfile) {
    print ERRLOG "No errors encountered during indexing.\n" 
	unless ($error || $errorflag);
}
close(ERRLOG) if $errfile;

print "Error encountered.\n" if ($errorflag);

if ($compile_error) {
    $logfile = "$attr{'CollectionRoot'}.log" unless $logfile;
    open(LOG, ">>$logfile");
    print LOG "\nCustom Filter File Warnings:\n";
    for (@WARNS) { 
	print LOG "$_\n";
    }
}


unlink("$root/collections/$database.pid");
exit 0;

## translated the index filter file into a format
## that architextIndex will understand.
sub compileExcludeFile {
    local($source, $target) = @_;
    local($expression, $type, $ruletype);
    if (! open(SOURCE, "$source")) {
	$error = "Couldn't open custom filter file, '$source'";
	return;
    }
    if (! open(TARGET, ">$target")) {
	$error = "Couldn't open custom filter target file, '$target'";
	return;
    }
    while (<SOURCE>) {
	next unless /\S/; ##skip blank lines
	next if /^\#/; ##allow comments
	s/^\s*//g; ##trim leading space
	s/\s*$//g; ##trim trailing space
	s/\s+/ /g; ##shrink internal space
	($ruletype, $expression, $type) = split(/\s/, $_);
	if (! $expression) {
	    ## old Exclusion Rules
	    print TARGET $_, "\n";
	    next;
	} elsif ($ruletype =~ /^dir$/i) {
	    $expression = "/$expression" unless ($expression =~ /^\// ||
						 $expression =~ /^\w:[\\\/]/);
	    $expression .= "/" unless ($expression =~ /[\/\\]$/); 
	    $expression = "^$expression"; ##anchor to head
	} elsif ($ruletype =~ /^subdir$/i) {
	    $expression = "/$expression" unless ($expression =~ /^[\/\\]/);
	    $expression .= "/" unless ($expression =~ /[\/\\]$/); 
	} elsif ($ruletype =~ /^file$/i) { 
	    $expression .= "\$"; ##anchor to end
        } elsif ($ruletype =~ /^regexp$/i) {
            print TARGET "$expression $type\n";
            next;
        } else {
            $compile_error = 1;
	    push(@WARNS, "Bad rule type '$ruletype' in Custom Filter File in line:\n\t'$_'");
            next;
    }

    if ($type && !(($type =~ /^TEXT$/i) || ($type =~ /^HTML$/i))) {
        $compile_error = 1;
        push(@WARNS, "Bad type '$type' in Custom Filter File in line:\n\t'$_'");
        next;
    }

    $expression =~ s|[\\\/]|[\\\\\\\/]|g; ## match forward or backslashes
    $expression =~ s/\./\\\./g; ## backslash periods
    $expression =~ s/\*/[^\\\/\\\\]\*/g; ## turn unix '*' to regexp version
    $expression =~ s/\?/[^\\\/\\\\]/g; ## turn unix '?' to regexp version

    print TARGET "$expression $type\n";


    }
    close(SOURCE);
    close(TARGET);
}




