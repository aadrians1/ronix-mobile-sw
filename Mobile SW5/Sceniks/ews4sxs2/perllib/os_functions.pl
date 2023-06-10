## This package contains the OS dependant functionality of EWS

##comment out the $ews_port variable on UNIX systems
##or else bad things will happen
#$ews_port = "NT";

## returns the name of the operating system
sub os_name {
    return "NT" if ($ews_port eq 'NT');
    return `uname -s`;
}

## kills a process, given the process ID
sub kill_process {
    local($pid, $root) = @_;
    local($killproc);
    if ($ews_port eq 'NT') {
	$killproc = "$root/killproc.exe";
	$killproc =~ s/\//\\/g;
	system("$killproc $pid");
    } else {
	kill 'TERM', $pid;
    }
}

##makes a directory, returns a non-zero error value
sub make_directory {
    local($directory) = @_;
    $directory =~ s/\\+/\\/g;
    $directory =~ s/\/+/\//g;
    if ($ews_port eq 'NT') {
	$directory =~ s/\//\\/g;
	return( system("mkdir $directory > NUL") );
    }
    return( system("/bin/mkdir $directory") );
}

sub make_files_readwriteable {
    local($files) = @_;
    return 1 if ($ews_port eq 'NT');
    return system("/bin/chmod a+rw $files");
}

##copies a space-separated list of files to a particular
##location, returns a non-zero error value
sub copy_files {
    local($files, $destination) = @_;
    if ($ews_port eq 'NT') {
	$files =~ s/\//\\/g;
	$destination =~ s/\//\\/g;
	return( system("copy $files $destination > NUL") );
    }
    return( system("/bin/cp $files $destination") );
}

sub executable {
    local($file) = @_;		
    if ($ews_port eq 'NT') {
	$file =~ s/\//\\/g;
	$file .= ".exe" unless ($file =~ /\.exe$/);
	return (-e $file);	
    }				
    return (-x $file);
}				
##makes a file executable, returns a non-zero error value
sub make_file_executable {
    local($file) = @_;
    return 0 if ($ews_port eq 'NT');
    return( system("/bin/chmod a+x $file") );
}

##removes a space-separated list of files, returns a non-zero error value
sub remove_files {
    local($files) = @_;
    local(@flist);
    $file =~ s/\/+/\//g;
    if ($ews_port eq 'NT') {
	$files =~ s/\//\\/g;
	return (system("del $files > NUL"));
    }
    return (system("/bin/rm -f $files")); 
}

##moves a space-separated list of files to a directory
##or file. returns a non-zero error value
sub move_files {
    local($files, $destination) = @_;
    if ($ews_port eq 'NT') {
	$files =~ s/\//\\/g;
	$destination =~ s/\//\\/g;
	return( system("move $files $destination > NUL") );
    }
    return( system("/bin/mv $files $destination") );
}

## copies the search script to the cgi-bin
## copies perl.exe to cgi-bin in the NT case
sub copy_search_file {
    local($file, $cgi, $root, $db) = @_;
    if ($ews_port eq 'NT') {
	return &copy_files("$root/doperl.exe", "$cgi/AT-${db}search.exe");
    } else {
	return &copy_files($file, $cgi);
    }
}

## removes all the files associated with a collection
sub remove_collection {
    local($name, $root, $config, $croot, $cgibin) = @_;
    local(@commands);
    local($newroot);
    local($rm) = "/bin/rm -f";
    $rm = "del" if ($ews_port eq 'NT');
    open(STDERR, ">/dev/null") unless ($ews_port eq 'NT');
    push(@commands, 
	 "$rm $root/collections/new/${name}*");
    push(@commands, 
	 "$rm $root/collections/${name}*");
    push(@commands, "$rm $croot*");
    push(@commands, 
	 "$rm $config/AT-${name}query.html");
    $newroot = $croot;
    $newroot =~ s/$name$//;
    $newroot .= "new/$name";
    push(@commands, "$rm $newroot*");
    push(@commands,
	 "$rm ${cgibin}/AT-${name}search.cgi");
    push(@commands,
	 "$rm $root/AT-${name}search.cgi");
    for (@commands) {
	$_ = &convert_file_names($_);
	$_ .= " > NUL" if ($ews_port eq 'NT');
	system($_);
    }
}

## creates support information to be sent to architext
sub create_support_info {
    local($root, $config, $version, $email, $description) = @_;
    open(STDERR, ">/dev/null") unless ($ews_port eq 'NT');
    if ($ews_port eq 'NT') {
	@commands = ('type ROOT/OS_VERSION',
		     'dir HTML', 'dir HTML',
		     'dir ROOT', 'dir ROOT/collections',
		     'dir ROOT/collections/new',
		     'dir ROOT', 'type ROOT/Architext.conf',
		     'type ROOT/collections/*.conf');
    } else {
	@commands = ('/bin/cat ROOT/OS_VERSION',
		     '/bin/ls -ld HTML', 'ls -l HTML',
		     '/bin/ls -ld ROOT', 'ls -ld ROOT/collections',
		     '/bin/ls -ld ROOT/collections/new',
		     '/bin/ls -lR ROOT', 'cat ROOT/Architext.conf',
		     '/bin/cat ROOT/collections/*.conf');
    }
	opendir(LOGS, "$config");
	@outfiles = grep(/\.log|err|prog$/, readdir(LOGS));
	for (@outfiles) {
	    push(@commands, "tail HTML/$_");
	}


    unlink("$root/support.out");
    open(SUPPORT, ">$root/support.out");
    $mailapp = &mailer($root); 
    open(MAIL, "| $mailapp ewssupport\@atext.com") if $email;
    print MAIL "To: ewssupport\@atext.com\n" if $email;
    print MAIL "Subject: Excite for Web Servers Support Information\n" if $email;
    
    print MAIL "Email: $email\n" if $email;
    print SUPPORT "Email: $email\n";

    print MAIL "Version: $version\nProblem description: $description\n" 
	if $email;
    print SUPPORT "Version: $version\nProblem Description: $description\n";
    for (@commands) {
	$_ =~ s/ROOT/$root/;
	$_ =~ s/HTML/$config/;
	$_ =~ s/\//\\/g if ($ews_port eq 'NT');
	print SUPPORT "$_\n";
	print MAIL "$_\n" if $email;
	print SUPPORT `$_`;
	print MAIL `$_` if $email;
	print MAIL "\n" if $email;
	print SUPPORT "\n";
	
    }
    
    close(MAIL) if $email;
    close(SUPPORT);
    
    
}				

## 'touches' a file
sub create_empty_file {
    local($file) = @_;
    local($exit);
    $exit = open(TFILE, ">$file");
    close(TFILE);
    return 1 unless $exit;
    return 0 if $exit;
}

## appends a line to a file
sub append_line_to_file {
    local($file, $line) = @_;
    local($exit, $oldfile);
    $oldfile = "$file.old";
    rename($file, $oldfile);
    open(OLDFILE, "$oldfile");
    open(TFILE, ">$file");
    print TFILE "$line\n";
    while (<OLDFILE>) {
	print TFILE $_;
    }
    close(TFILE);
    close(OLDFILE);
    unlink($oldfile);
    &make_files_readwriteable($file);
    return $exit;
}

##true if $file is in a subdirectory of $root
sub underHtmlRoot {
    local($root, $file) = @_;
    local($prefix);
    return 1 if (! &Architext'restrictBeneathRoot());
    $root =~ s|\\|\/|g;
    $file =~ s|\\|\/|g;
    $root =~ s|\/$||;
    $file =~ s|\/$||;
    $prefix = substr($file, 0, length($root));
    return 1 if ($prefix eq $root);
    return 0; 
}

## spawns the indexing daemon
sub spawn_indexer {
    local($aindex, $perl, $dbname, $logfile, $progfile, $errfile) = @_;
    local($ipid, $root);
    if ($ews_port eq 'NT') {
	## use NT perl's 'spawn' command to launch indexer
	$root = $perl;
	$root =~ s/[\\\/]perl$//;
	$incommand = "$root/spawnproc.exe $perl -x $aindex $dbname $logfile $progfile $errfile";
	$incommand = &convert_file_names($incommand);
	system($incommand);
    } else {
	## increase usage limits on BSDI machines
	$extra_command = "unlimit memoryuse; unlimit datasize;"
	    if (`uname` =~ /BSD/i);
	$!="";
	unless (fork) { # this is the child
	    unless (fork) {		# child's child
		sleep 1 until getppid == 1;
		## &Closer closes file descriptors before execing to workaround
		## NCSA bug in httpd version 1.3
		&Closer();
		## third and fourth args make indexer build prog and log files
		exec("$extra_command $aindex $dbname $logfile $progfile $errfile");
	    }			 
	    ##first child exits quickly
	    exit 0;			 
	}
	
	wait; ## parent reaps first child quickly
    }
}


## closes the first 20 filehandles to kill unclosed socket
## from NCSA httpd 1.3 (also in some netscape servers), 
## which is a bug that prevents
## indexing process from being able to background.
sub Closer {
    return if ($ews_port eq 'NT');
    if (`uname -s` =~ /irix/i) {
# /usr/include/sys.s.
	$SYS_close = 1006;
    }
    else {
        $SYS_close = 6;
    }
    die "Must define \$SYS_close" unless defined($SYS_close);
    if (`uname -s` !~ /aix/i) {
	for ($i=0; $i<20; $i++) {
	    syscall($SYS_close, $i+0);
	}			
    }
}

## returns the name of the mailer program
sub mailer {
    local($root) = @_;
    return &convert_to_NT("$root/dropmail.exe") if ($ews_port eq 'NT');
    return "/bin/mail";
}

## converts a filename to an NT filename (slashes to backslashes)
sub convert_to_NT {
    local($file) = @_;
    $file =~ s/\//\\/g;
    return $file;
}

## converts slashes to backslashes unless we're in UNIX land.
sub convert_file_names {
    local($file) = @_;
    return $file unless ($ews_port eq 'NT');
    $file =~ s/\//\\/g;
    return $file;
}


##turns a space separated list of files into a list
##allows for spaces in filenames by obeying single quotes
##around filenames

sub splitFileList {
   local($files) = @_;
   local(@final_list);
   local($new);
   for (split(/\s+/, $files)) {
    if ($new) {
        $new .= " $_";
    } else {
        $new = $_ if (/^\'/);
    }
    push(@final_list, $_) unless $new;
    if (/\'$/) {
        push(@final_list, $new);
        undef $new;
    }
   }
  @final_list;
}

1;




