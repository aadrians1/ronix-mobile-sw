## Unix Version Patch -- architext_query.pl
## This updated version of this library file removes
## a security hole that made shell-based hacking possible via CGI
## This file last updated 1/16/98

## Architext perl library
## Copyright (c) 1996 Excite, Inc.

package ArchitextQuery;
require 'afeatures.pl'; 
require 'os_functions.pl';

## should we do QBE?
sub qbeMode {
    return $query_by_example_mode;
}

## should we do summaries?
sub summaryMode {
    return $summary_mode;
}

## should scripts do subject grouping?
sub asgMode {
    return $subject_group_mode;
}

## are we in custom format mode?
sub customFormat {
    return $custom_format;
}

sub helpPath {
    return $help_path;
}

## is notifier enabled?
sub notifyMode {
    return $notifier_on;
}

sub NSOn {
    $no_stemming_mode; 
}

sub indexHtmlComments {
    return $index_html_comments;
}

## also checks for existence of fielded data which implies new
## query syntax 
sub checkForIndex {
    local(%form) = @_;
    if (! -e "$form{'index'}.dat") {
	print "<p><h1>Error: No Index to query on.</h1>\n";
	print "<p>Apparently, there is no index available for this\n";
	print "collection, so queries cannot be made at this time.";
	exit(0);
    }
    return (-e "$form{'index'}.fidx");
}

## returns value of the $show_legend variable, 'top' or 'bottom'
## or nothing at all.
sub legendLocation {
    return $show_legend;
}

## returns value of $restrict_beneath_document_root variable
sub restrictBeneathRoot {
    return $restrict_beneath_document_root;
}

sub errorIcon {
    local($url) = @_;
    return "<img src=\"${url}pictures/$error_icon\">";
}

sub indexTimeMapping {
    return $index_time_mapping;
}

## forwards the search to www.excite.com if appropriate
sub directQuery {
    local($search, $mode, $db, $source, $backlink, $linktext, $logfile) = @_;
    local($url);

    $db = 'excite_NetSearch' if ($source eq 'excite');
    &ArchitextQuery'logQuery($db, $search, $logfile);
    return unless ($source eq 'excite');

    if ($backlink eq '*') {
	$backlink = "";
    } else {
	$backlink = &httpize($backlink);
	$backlink = "&backlink=$backlink";
    }
    if ($linktext eq '*') {
	$linktext = "";
    } else {
	$linktext = &httpize($linktext);
	$linktext = "&bltext=$linktext";
    }

    $search =~ s/\s/\+/g;
    if ($mode eq "simple") {
	$mode = "Keyword";
    } else {
	$mode = "Concept";
    }
    $url = "http://www.excite.com/search.gw?trace=ews1.1&search=$search&searchType=$mode&showqbe=1$backlink$linktext";
    print "Location: $url\n\n";
    print "<h2>Your browser does not support redirection.</h2>\n";
    print "<h2><a href=\"$url\">Click here to continue.</a><h2>\n";
    exit(0);
}

sub logQuery {
    local($collection, $query, $logfile) = @_;
    local($qtime);
    return unless $logfile;
    if (mkdir("$logfile.lck", 0)) {
	if (-e $logfile) {
	    open(QLOG, ">>$logfile");
	} else {
	    open(QLOG, ">$logfile");
	}
	chop($qtime = &main'ctime(time));
	$query =~ s/\s/ /g;
	print QLOG "[$qtime] collection=$collection search='$query'\n";
	close QLOG; 
	rmdir("$logfile.lck");
    } else {
	## clean up any locks that are too old
	## .000023 days is roughly 2 seconds
	rmdir("logfile.lck") if ((-M "$logfile.lck") > 0.000023 );
    }
}

## This subroutine execs a subprocess, sending its output to CMD_OUT
## and its errors to CMD_ERR. It should be invoked by a caller like
## this:
## 	&Architext'execSubprocess(*MY_OUT, *MY_ERR, "some command");
## Note that the filehandles must be prefixed by '*'.
##
sub execSubprocess {
    local(*CMD_OUT, *CMD_ERR, @cmd) = @_;
    local(*CMD_WR_ERR);
    pipe(CMD_ERR, CMD_WR_ERR);
    open(CMD_OUT, "-|") || do { open(STDERR, ">&CMD_WR_ERR"); exec @cmd; };
    close(CMD_WR_ERR);
}

## Converts an error message into a slightly nicer HTML error string.
sub html_errorstr {
    local($htmlmsg) = @_;
    "<I>Query Error:</I> $htmlmsg\n";
}

## This subroutine executes the actual query and saves the lines that
## it gets back. Other subroutines use the lines to print useful
## information.
sub MakeQuery {
    local(%form) = @_;
    local($queryprog, $configfile, $query, $timeout);
    $queryprog = $form{'binary'};
    $configfile = "$form{'root'}/collections/$form{'db'}.cf";
    $query = $form{'search'};
	
    local(*QUERY, $errstr, @queryresult);
    local($results);
    ## Make sure all the files are in place.
    if (! &executable($queryprog)) {
	&log_error("query program '$queryprog' does not exist " .
		   "or is not executable");
	return &html_errorstr("Cannot run query program '$queryprog'");
    }

    if (!$configfile || ! -r $configfile) {
	&log_error("cannot find config file '$configfile'");
	return &html_errorstr("Cannot find configuration file");
    }

    if (! ($query =~ /\S/)) {
	&log_error("empty query");
	return &html_errorstr("Empty query string");
    }

    ## Strip out extra space in the query.
    $query =~ s/\s+/ /g;

    $syntax_flag = "-nq" if ($form{'newquery'});

    ## check for QBE, ASG  or old-school summaries here...
    undef $syntax_flag if ($query =~ /\(doc\s+r\=\d+\)/);
    undef $syntax_flag if ($query =~ /\(sum.*\d+\)/);
    undef $syntax_flag if ($query =~ /^\(g\s/);

    ## Should we do a default concept-based query?
    if (($query !~ /^\(/) && (! $syntax_flag)) {
    	$query = "(concept $query)";
    }
    
    ## do the search
    ## Patch changes begin here -- RAM 1/13/98
    $timeout = $maximum_query_time if $maximum_query_time;
    $queryprog = &convert_file_names($queryprog); 
    $configfile = &convert_file_names($configfile);
    @qcommand = ($queryprog, "-C", $configfile, 
		 "-q", $query, "-num", $max_docs_to_return);
    ## add timeout flag if appropriate
    push @qcommand, ("-to", $timeout) if $timeout;
    push @qcommand, ($syntax_flag) if $syntax_flag;
    ##use exec() to prevent shell invocation
    open(QUERY, "-|") || do { exec @qcommand };
    ## Accumulate the results.
    while (<QUERY>) {
	chop;
	if (/^ARCHITEXTERROR:/) {
	    s/^ARCHITEXTERROR://;
	    $errstr .= $_ ;
	    next;
	}
	$results = 1 if /\S/;
	push(@queryresult, $_);
    }
    ##patch changes end here -- RAM 1/13/98

    if (!$results && !$errstr) {
	$errstr =  "<p><b>No documents found.</b>";
    }

    ##ECO -- specialize message if all words were stopped
    $errstr = "<p><b>Error:</b> All your search words were considered too commonplace. (e.g. <i>a</i>, <i>and</i>, or <i>the</i>)  Please try again using less common words." if ($errstr =~ /All query words were stemmed/);
    $errstr = "success" unless $errstr;
    $errstr = "success" if ($errstr =~ /^ld\.so/); ##ignore runtime ld warnings
    $errstr = "summary" 
	if ((($errstr=~/documents found/) || ($errstr eq "success")) 
	    && ($query =~ /^\(sum.+\d+\)/));
    $errstr = "dump" 
	if (($errstr eq "success") && ($query =~ /^\(dump.+\d+\)/));
    return ($errstr, @queryresult);
}

## Logs an error. Here, 'log' just means print to STDERR, because most
## httpds redirect STDERR to error_log.
sub log_error {
    local($logmsg) = @_;
    local($time, $myname);
    ## Get the time
    chop($time = &main'ctime(time));
    ## And get the name of the script currently running
    ($myname) = ($0 =~ m|/([^/]+)$|);
    print STDERR "[$time] $myname: $logmsg\n";
}


## simply outputs the summary on to the page with paragraph breaks
## between pages.  optionally truncates the summary to a certain
## amount of bytes if that has been specified
sub SummaryOutput {
    local($title, $url, *query) = @_;
    local($line, $total_length, $line_length);
    local($original_link);
    if ($summary_link_mode) {
	$original_link = "for <a href=\"$url\">$title</a>"
	    unless (($title eq '*') || ($url eq '*'));
    }
    print "<h2> Summary $original_link</h2><p>\n";
    for $line (@query) {
	$line =~ s/~~~/<p>/g;
	$line_length = length($line);
	if ($maximum_summary_length && 
	    (($total_length + $line_length) > $maximum_summary_length)) {
	    $line = 
		substr($line, 0, ($maximum_summary_length - $total_length));
	    print "$line. . .";
	    last;
	}
	$total_length += $line_length;
	print $line;
    }
}

## if not in $restrict_under_html_root mode, simply output the doc, one
## line at a time
sub DocumentOutput {
    local(*query) = @_;
    print "<PRE>";
    for $line (@query){
	print "$line\n";
    }
    print "</PRE>";
}

## this function takes a line of MakeQuery output, and returns
## an HTML'ized line of output
sub processResultLine {
    local($line, $qbeimg, $sumimg, %form) = @_;
    local($shown, $max, $ballsrc, $path, $result_line, $special_summary);
    
    ## Some perl code to transform a filename to a URL. The URL is in
    ## $_. A likely choice would be something like 
    ## 's|^/usr/local/www/html/|http:/|'.
    $urledit = $form{'urledit'};
    $thresh = $form{'thresh'};
    $format = $form{'format'};
    $special_format = $form{'special'};
    $numtoshow = $form{'num'};
    $scorefun = $form{'scorefun'};
    local($num, $score, $ball, $url, $title, $special_summary) = split(/\t/, $line);
    
	## what happen here???
	return 0 unless ($line =~ /\S/);
    return 0 if (($num =~ /\D/) || ($score =~ /\D/));

    $path = $url;
    if ($title =~ /No title/) {
	$url =~ /\/?([^\/]+)$/;
	$title = "$1 ";
    }
    if ((!$title) || ($title =~ /Untitled/)) {
	$title = $url;
	$title =~ /\/?([^\/]+)$/;
	## when the html file has no title, or if it is a text file,
	## we just want to print out the filename (minus the path)
	$title = "$1 ";
    }
    $title =~ s/^\s+//g;
    $title =~ s/\s+$//g;
    
    if ($scorefun eq 'scale') {
	## Just multiply it by 100000.
	$score *= 100000;
	$score = sprintf("%05.0f", $score);
    } elsif ($scorefun eq 'log') {
	## log-based function that gives a smaller range of
	## results.
	$score = 10 + log($score) unless ($score == 0);
	$score = 0 if $score < 0;
	$score = sprintf("%04.3f", $score);
    } elsif ($scorefun eq 'nothing') {
	$score = sprintf("%02d%", $score); ##ECO
    }

    $max = $score unless $max;
    ##last if ($score < $max*$thresh);

    $url = &addDumpOperator($url, $num, $form{'db'}, $form{'hroot'})
	if (! $restrict_beneath_document_root);

    ## eval the URL.
    if ($urledit) {
	eval '$_=$url;' . $urledit;
	$url = $_ unless $@;
    }

    $ourl = $url;
    $url = &modifyAnchor($url);

    $ballsrc = 
	"<img border=0 src=\"$form{'aurl'}pictures/$icons{$ball}\">";
    if (! $graphic_relevance_mode) {
	$ballsrc = "<b>-</b>";
	$ballsrc = "<b>+</b>" if ($ball == 1);
    }
    $qbeimg = $ballsrc;

    ##calculate summary and QBE URLs
    if ($query_by_example_mode) {
	$spage = "searchpage=$form{'searchpage'}" if $form{'searchpage'};
	$spage = &httpize($spage);
	$qbe = "<A HREF=\"AT-$form{'db'}search$script_suffix?doc=d$num&$spage\">$qbeimg</A>"; 
    }
    $qbe = $qbeimg unless $qbe;

    if ($summary_mode) {
	if ($summary_link_mode) {
	    $sum_title_info = "&stitle=$title&surl=$ourl";
	    $sum_title_info = &httpize($sum_title_info);
	}
	$sum = "<A HREF=\"AT-$form{'db'}search$script_suffix?sum=d$num$sum_title_info\">$sumimg</A>";
    }

    ## mark the document's url
    $url =~ s/HREF/architext=result HREF/;

    undef $special_summary unless $inline_summaries;

    if (! $special_summary) {
      $result_line = &formatExpand($format, 'n', $num, 't', $title, 'u', 
	  	  		   $url, 's', $score, 'b', $qbe, 'd', $sum);
    } else {
      $result_line = &formatExpand($special_format, 'n', $num, 
	                           't', $title, 'u', 
	  	  		   $url, 's', $score, 'b', $qbe, 
                                   'd', $special_summary);
    }
    if ($customize_result_list) {
	$qbe = "(empty)" unless $qbe;
	$sum = "(empty)" unless $sum;
	$sum = $special_summary if $special_summary;
	$result_line = 
	    &customize_result_list_line($form{'db'}, $path, 
					$form{'hroot'}, $qbe, 
					$score, $title, $sum, 
					$result_line);
    }
    ##make sure URLs all have forward slashes
    $result_line =~ s/\\/\//g;
    $result_line;
}

## This subroutine takes the output from MakeQuery and HTMLizes it
## into a nice list. It takes a few options, described below.
sub HtmlList {
    local(*query, %form) = @_;
    local($qbeimg, $sumimg);
    local($result_line);

    ## this bit of code figures out whether to use icons or
    ## text for the summary and qbe URLs
    if ($icons{'qbe'}) {
	$qbeimg = 
	    qq(<img border=0 src="$form{'aurl'}pictures/$icons{'qbe'}">);
    } else {
	$qbeimg = "<b>Q</b>";
    }
    if ($icons{'sum'}) {
	$sumimg = 
	    qq(<img border=0 src="$form{'aurl'}pictures/$icons{'sum'}">);
    } else {
	$sumimg = "(summary)";
    }

    ## The format string used to print the URL. Kindof like printf,
    ## see below for the format codes.
    $form{'format'} = $form{'format'} ? $form{'format'} :
	qq(%b %s %u <b>%t</b></A> %d <br>\n);
##qq(%b %s %q %u <b>%t</b></A> %d <br>\n);
    $form{'special'} = 	
         qq(%b %s %u <b>%t</b></A> <ul> <i>Summary</i>: %d </ul>\n);

    ## The number of documents to show.
    $form{'num'} = $form{'num'} ? $form{'num'} : $max_docs_to_return;

    ## The scoring function. See below for details.
    $form{'scorefun'}  = $form{'scorefun'} ? $form{'scorefun'} : "nothing";

    ## A threshhold for displaying results.
    $form{'thresh'} = $form{'thresh'} ? $form{'thresh'} : 0.02;

    for $line (@query) {
	$result_line = &processResultLine($line,$qbeimg,$sumimg,%form);
	
	if ($result_line) {
	    print $result_line;
	    last if (++$shown >= $numtoshow);
	}
    }
    print "<p><p>";
}

## collects the document numbers and relevance scores
## into a form to be used for auto subject grouping
sub PrepareGather {
    local(*query) = @_;
    local($line, $title, $order);
    $name = "docs" unless $name;

    $order = 0;
    $args = "";
    for $line (@query) {
	($num, $score, $ball, $url, $title) = split(/\t/, $line);
	if (($num !~ /\D/) && ($ball !~ /\D/)) {
	    $args .= "$num|$ball|$order ";
	    $order++;
	    last if (!$show_additional_docs_in_grouping && 
		     ($order >= $max_docs_to_return)); 
	}
    }
    chop($args);		# Kill trailing ' '
    return $args;
}


sub MakeGather {
    local(%form) = @_;
    local($queryprog, $configfile, $docstr, $timeout);
    local(*QUERY, $errstr, @queryresult, @docs, @udocs);
    local($groupnum, %groupwords, %grouparts, %titles, %colors, $num, $query);
    local(%groupcount);
    local(%rels);
    local(%newgrouparts);
    local(%urls, %second_urls);
    local(%second_grouparts, %second_titles);
    local(%summaries, %second_summaries);
    local($pastbest, $totalarts);		
    local($gopen_ball, $ballsrc, $ndoc, $bdoc, $adoc, $qbe, $sum);
    local($qbeimg, $sumimg);
    local($result_line, $path, $sum_line);

    $queryprog = $form{'binary'};
    $configfile = "$form{'root'}/collections/$form{'db'}.cf";
    $docstr = $form{'docs'};

    ## this bit of code figures out whether to use icons or
    ## text for the summary and qbe URLs
    if ($icons{'qbe'}) {
	$qbeimg = 
	    qq(<img border=0 src="$form{'aurl'}pictures/$icons{'qbe'}">);
    } else {
	$qbeimg = "<b>Q</b>";
    }
    if ($icons{'sum'}) {
	$sumimg = 
	    qq(<img border=0 src="$form{'aurl'}pictures/$icons{'sum'}">);
    } else {
	$sumimg = "(summary)";
    }

    ## Make sure all the files are in place.
    if (! &executable($queryprog)) {
	&log_error("query program '$queryprog' does not exist " .
		   "or is not executable");
	return &html_errorstr("Cannot run query program '$queryprog'");
    }

    if (!$configfile || ! -r $configfile) {
	&log_error("cannot find config file '$configfile'");
	return &html_errorstr("Cannot find configuration file");
    }

    if ($docstr eq '1') {
	&log_error("You cannot do a subject-grouping on zero documents.");
	return "You cannot do a subject-grouping on zero documents.";
    }
 
    ## split docs and colored ball information into separate arrays
    @udocs = split(' ', $docstr);
    while ($adoc = pop(@udocs)) {
	($ndoc, $bdoc, $rdoc) = split(/\|/, $adoc);
	$colors{$ndoc} = $bdoc;
	$rels{$ndoc} = $rdoc;
	unshift(@docs, $ndoc);
    }

    if (!@docs) {
	&log_error("No articles to gather");
	return &html_errorstr("Invalid gather request");
    }

    $query = $form{'gather_cmd'};
    $query = 
	"(g $gather_options g=$number_of_subject_groups (. DOCS))" 
	    unless $query;
    $query =~ s/DOCS/@docs/g;

    $format_gopen = $form{'format_gopen'} ? $form{'format_gopen'} :
	"%b <i>Group %g:</i> <b>%w</b><ul>\n";
    $format_gclose = $form{'format_gclose'} ? $form{'format_gclose'} :
	"</ul>\n";
    $format_gentry = $form{'format_gentry'} ? $form{'format_gentry'} :
	"%b %u <b>%t</b></a> %s <br>\n";
    $format_gentry_special = $form{'format_gentry'} ? $form{'format_gentry'} :
	"%b %u <b>%t</b></a> <ul> <i> Summary</i>: %s </ul>\n";

    $urledit = $form{'urledit'};

    ##patch changes -- RAM 1/13/98
    $timeout = $maximum_query_time if $maximum_query_time;
    $queryprog = &convert_file_names($queryprog);
    $configfile = &convert_file_names($configfile);    
    @qcommand = ($queryprog, "-C", "$configfile",
		 "-q", $query);
    push @qcommand, ("-to", $timeout) if $timeout;
    open(QUERY, "-|") || do { exec @qcommand };

    $groupnum = 0;
    $totalarts = 0;
    while (<QUERY>) {
	chop;
	if (/^ARCHITEXTERROR:/) {
	    s/^ARCHITEXTERROR://;
	    $errstr .= $_;
	    next;
	}
	if (/=========/) {
	    $pastbest = 0;
	    next;
	} 
	elsif (/-----/) {
	    $pastbest = 1;
	    next;
	} 
	elsif (/^Summary words: (.*)$/) {
	    $groupnum++;
	    $groupcount{$groupnum} = 0;
	    $groupwords{$groupnum} = $1;
	    $groupwords{$groupnum} =~ s/\s+/, /g;
	} 
	elsif ($pastbest && (/^\s+(\d+)\s+([^\t]*)\t(.*)$/)) {
	    $totalarts++;
	    $groupcount{$groupnum}++;
	    $second_urls{$1} = $2;
	    ($second_titles{$1}, $sum_line) = split('\t', $3);
	    $second_summaries{$1} = $sum_line if $sum_line;
	    $second_tkey = $1;
	    $second_grouparts{$groupnum} .= "$1 ";
	    if ($second_titles{$second_tkey} =~ /No title/) {
		$second_urls{$second_tkey} =~ /\/?([^\/]+)$/;
		$second_titles{$second_tkey} = "$1 ";
	    }
	    if ((!$second_titles{$second_tkey}) || ($second_titles{$second_tkey} =~ /Untitled/)) {
		## when the html file has no title, or if it is a text file,
                ## we just want to print out the filename (minus the path)
                $title = $second_urls{$second_tkey};
		$title =~ /\/?([^\/]+)$/;
		$title = "$1 ";
		$second_titles{$second_tkey} = $title;		    
	     }
	} 
	elsif (/^\s+(\d+)\s+([^\t]*)\t(.*)$/) {
	    $totalarts++;
	    $groupcount{$groupnum}++;
	    $urls{$1} = $2;
	    ($titles{$1}, $sum_line) = split('\t', $3);
	    $summaries{$1} = $sum_line if $sum_line;
	    $tkey = $1;
	    $grouparts{$groupnum} .= "$1 ";
	    if ($titles{$tkey} =~ /No title/) {
		$urls{$tkey} =~ /\/?([^\/]+)$/;
		$titles{$tkey} = "$1 ";
	    }
	    if (!$titles{$tkey} || ($titles{$tkey} =~ /Untitled/)) {
		## when the html file has no title, or if it is a text file,
                ## we just want to print out the filename (minus the path)
                $title = $urls{$tkey};
		$title =~ /\/?([^\/]+)$/;
		$title = "$1 ";
		$titles{$tkey} = $title;
	     }
	} else {
	    # print "Ignoring: <CODE>$_</CODE><P>\n";
	}
    }
	
    ##end patch RAM 1/13/98
    
    if ($errstr =~ /\S/) {
	return $errstr unless ($errstr =~ /^ld\.so/); ## ignore ld runtime 
    }

    ## code here will throw relevance 1 and 2 documents from
    ## the less-central document list in to the final
    ## output list
    for $g (keys %second_grouparts) {
	for $num (split(/\s+/, $second_grouparts{$g})) {
	    if ($colors{$num} == 1 || $colors{$num} == 2) {
		$grouparts{$g} = "$num $grouparts{$g}";
		$titles{$num} = $second_titles{$num};
		$urls{$num} = $second_urls{$num};
		$summaries{$num} = $second_summaries{$num};
	    }
	}
    }
    ## this code sorts the subgroups based on the relevance in the
    ## original query
    for $g (keys %grouparts) {
	for $h (sort { $rels{$b} <=> $rels{$a} } split(' ', $grouparts{$g})) {
	    $newgrouparts{$g} = "$h $newgrouparts{$g}";
	}
	
    }
    %grouparts = %newgrouparts;

    $groupnum = 1;
    for $g (sort { length($grouparts{$b}) <=> length($grouparts{$a}) }
	 keys %grouparts) {

	print &formatExpand($format_gopen,
			    'g', $groupnum,
			    'w', $groupwords{$g},
			    'b', $gopen_ball);

	$grouparts{$g} =~ s/\s+$//;
	$total_for_group = 0;
	for $num (split(/\s+/, $grouparts{$g})) {
	    $total_for_group++;
	    ## code here limits number of documents in a sub group
	    if ($total_for_group > $max_docs_per_subgroup) {
		last unless ($rels{$num} > $max_docs_to_return);
	    }
	    $url = $urls{$num};
	    $path = $url;

	    $url = &addDumpOperator($url, $num, $form{'db'}, $form{'hroot'})
		if (! $restrict_beneath_document_root);

	    if ($urledit) {
		eval '$_=$url;' . $urledit;
		$url = $_ unless $@;
	    }
	    $ourl = $url;
	    $url = &modifyAnchor($url);
	    ## figure out the appropriate colored ball to put here
	    $ballsrc = 
		"<img border=0 src=\"$form{'aurl'}pictures/$icons{$colors{$num}}\">";
	    if (! $graphic_relevance_mode) {
		$ballsrc = "<b>-</b>";
		$ballsrc = "<b>+</b>" if ($colors{$num} == 1);
	    }
	    $qbeimg = $ballsrc;

	    ##calculate summary and QBE URLs
	    if ($query_by_example_mode) {
		$spage = "searchpage=$form{'searchpage'}" 
		    if $form{'searchpage'};
		$spage=&httpize($spage);
		$qbe = "<A HREF=\"AT-$form{'db'}search$script_suffix?doc=d$num&$spage\">$qbeimg</A>";
	    }
	    $qbe = $qbeimg unless $qbe;
	    $titles{$num} =~ s/^\s+//g;
	    $titles{$num} =~ s/\s+$//g;
	    if ($summary_mode) {
		if ($summary_link_mode) {
		    $sum_title_info = "&stitle=$titles{$num}&surl=$ourl";
		    $sum_title_info = &httpize($sum_title_info);
		}
		$sum = "<A HREF=\"AT-$form{'db'}search$script_suffix?sum=d$num$sum_title_info\">$sumimg</A>";
	    }
	    $summaries{$num} = "" unless $inline_summaries;
	if (! $summaries{$num}) {
	    $result_line = &formatExpand($format_gentry,
					 'g', $groupnum,
					 'n', $num,
					 'w', $groupwords{$g},
					 't', $titles{$num},
					 'u', $url,
					 'b', $qbe,
					 's', $sum);
        } else {
       	    $result_line = &formatExpand($format_gentry_special,
	                                 'g', $groupnum,
					 'n', $num,
					 'w', $groupwords{$g},
					 't', $titles{$num},
					 'u', $url,
					 'b', $qbe,
					 's', $summaries{$num});
}
					 
	    if ($customize_result_list) {
		$qbe = "(empty)" unless $qbe;
		$sum = "(empty)" unless $sum;
		$sum = $summaries{$num} if $summaries{$num};
		$result_line = &customize_grouping_line($form{'db'}, $path, 
							$form{'hroot'},
							$qbe, 
							$titles{$num},
							$sum, 
							$result_line);
	    }
	    ##make sure URLs all have forward slashes
	    $result_line =~ s/\\/\//g;
	    print $result_line;
	}
	print &formatExpand($format_gclose,
			    'g', $groupnum,
			    'w', $groupwords{$g});
	$groupnum++;
    }
    ## check if this was a good group of articles to group, if not
    ## advise the user.
    if (! &goodGrouping($totalarts, %groupcount)) {
	print <<EOF;
</ul><p> Note:  Subject Grouping this particular set of query results 
has yielded a number of small groups.  This
indicates either a small document collection on this server, 
a small set of query results,  or a
set of results that does not contain many subtopics.
EOF
    ;

    }
    return "success";
}

## checks for less-than-deal subject grouping results
sub goodGrouping {
    local($numarticles, %groups) = @_;
    local($g, $numgood);
    if (! $advise_on_gather) { return 1; }
    $numgood = 0;
    for $g (keys %groups) {
	$val = $groups{$g} / $numarticles;
	if (($groups{$g} / $numarticles) > 0.04 ) {
	    $numgood++;
	}
    }
    if ($numgood > 1) { return 1; }
    return 0;
}

sub formatExpand {
    local($format, %fmt) = @_;
    local($str) = $format;

    $str =~ s/\%\%/\377/g;
    for (keys %fmt) {
	$str =~ s/\%$_/$fmt{$_}/g;
    }
    $str =~ s/\377/%/g;

    $str;
}

## This function takes arguments in standard <FORM> format and unpacks
## them into an associative array.
sub unpackFormArgs {
    local($argstr) = @_;
    local($key, $val, %form);

    ## Save in an associative array...
    for (split(/\&/, $argstr)) {
	($key, $val) = split(/=/);
	$form{$key} = &unhttpize($val);
    }

    %form;
}

## This function reads arguments from a GET method, a POST method, or
## the command line (the latter for testing purposes). It then unpacks
## them and returns the associative array.
sub readFormArgs {
    local($args, $len);

    $len = $ENV{'CONTENT_LENGTH'};
    if ($len) {
	if (read(STDIN, $args, $len) != $len) { die "Couldn't read POST"; }
    }
    if (!$args) {
        $args = $ENV{'QUERY_STRING'};
    }
    if (!$args) {
	$args = join('&', @ARGV);
    }
    %dform = &unpackFormArgs($args);
    %dform;
}

## Converts a URL-encoded string into its original form.
sub unhttpize {
    local($str) = @_;
    $str =~ s/\+/ /g;
    $str =~ s/\%(..)/pack("c",hex($1))/ge;
    $str;
}

## URL-encodes a string.
sub httpize {
    local($str) = @_;
    $str =~ s/([^ \&\=\w])/sprintf("%%%02X",ord($1))/ge;
    $str =~ s/ /+/g;
    $str;
}

## Prints out the standard Architext header.
sub printHeader {
    local($path, $title, $head) = @_;
    $head = $title unless $head;
    &printHttpHeader;
    print "<head><title> $title </title></head><body>\n";
    &showForm() if $debugmode;
    print <<EOP;
<h2> <img src="${path}pictures/$admin_banner"><P>$head </h2>
EOP
    ;
}

sub printHttpHeader {
    print "Content-Type: text/html\n\n";
}



sub queryError {
    local($errstr) = @_;
    print "<h2> Error! </h2>\n" unless 
	(($errstr eq '<p><b>No documents found.</b>') ||
	 ($errstr =~ /No documents found/));
    print "<p><b>No documents found.<b><p>" if ($errstr =~ /No documents found/);
    print $errstr unless ($errstr =~ /No documents found/) ;
    exit(0) unless ($errstr =~ /No documents found/);
	## VL - added this to return null if everything is OK
	## may be OK to remove exit(0) as well
	return "";
}

## tells the user what his query was on the result page, if
## appropriate.
sub showSearchString {
    local(%sform) = @_;
    local($search);
    $search = $sform{'psearch'};
    $search = "(Query-By-Example)" if $sform{'doc'};
    ##$search =~ s|\W| |g;
    print 
	"\n<br>excite for web servers found documents about: <b>$search</b>\n"
	    unless (($sform{'sum'}) || ($sform{'dump'}));
    &callbackButton($sform{'aurl'}, $sform{'searchpage'});
    &explainResults($sform{'aurl'});
    print "<p>";
				
}

## ECO -- explains the icons on the results list
sub explainResults {
    local($aurl) = @_;
    local($qbe, $summary, $describe);
    
    $qbe = "; click icons to find similar documents" if ($query_by_example_mode && $graphic_relevance_mode);
    $qbe = "; click <b>+</b> or <b>-</b> to find similar documents" if ($query_by_example_mode && !$graphic_relevance_mode);
    $summary = "; click <b>(summary)</b> for a short summary of the document"
	if ($summary_mode && !$inline_summaries);
    if ($show_legend) {
	print <<EOF;
<p>
<FONT SIZE=2>
<img src="${aurl}pictures/$icons{'1'}" alt="[higher confidence]">
- higher confidence,
<img src="${aurl}pictures/$icons{'2'}" alt="[lower confidence]">
- lower confidence$qbe$summary
</FONT>

EOF
    ;
    }
}

##ECO -- returns 'confidence' or 'subject' based on value of 
##grouped by radiobuttons or original search form
sub getSearchMode {
    local(%form) = @_;
    local($xcoord);
    return 'confidence' unless $form{'groupby.x'};
    $xcoord = $form{'groupby.x'};
    $xcoord =~ s/\D//g;
    return 'subject' if (($xcoord > 225) && ($form{'smode'} eq 'confidence'));
    return 'subject' if (($xcoord > 194) && ($form{'smode'} eq 'subject'));
    return 'confidence';
} 

## ECO -- shows the appropriate gif based on subject or confidence grouping
sub showSearchMode {
    local($mode, %form) = @_;
    local($aurl, $orig, $searchpage, $docs, $qbe);
    local($image);
    $aurl = $form{'aurl'};
    $orig = $form{'search'};	
    $searchpage = $form{'searchpage'};
    $docs = $form{'docs'};
    $qbe = $form{'doc'};

    return unless $subject_group_mode;
    $image = $confidence_image if ($mode eq 'confidence');
    $image = $subject_image if ($mode eq 'subject');
    $qbe = "<INPUT TYPE=hidden NAME=\"doc\" VALUE=\"$qbe\">" if $qbe;
    print <<EOF;
<FORM ACTION="AT-$form{'db'}search$script_suffix" METHOD=POST>
<INPUT TYPE=image BORDER=0 NAME="groupby" SRC="${aurl}pictures/$image">
<INPUT TYPE=hidden NAME="docs" VALUE="$docs">
<INPUT TYPE=hidden NAME="smode" VALUE="$mode">
<INPUT TYPE=hidden NAME="mode" VALUE="$form{'mode'}">
<INPUT TYPE=hidden NAME="searchpage" VALUE="$searchpage">
<INPUT TYPE=hidden NAME="search" VALUE="$form{'psearch'}">
$qbe
</FORM>
EOF
    ;
}

## ECO -- provides a "New Search" button on hitlist page
## only is $new_query_button is enabled and HTTP_REFERER environment var
## is available
sub callbackButton {
    local($aurl, $callback) = @_;
    if ($new_query_button && $callback) {
	print qq(  <a href="$callback"><img src="${aurl}pictures/AT-new_search_button.gif" ALT="New Search" BORDER=0 WIDTH=104 HEIGHT=20 ALIGN="absmiddle"></a>);
    }
}

##this routine allows the query script to generate appropriate search
##strings for concept queries, query-by-example, and summaries.
sub setSearchString {
    local(%sform) = @_;
    local($search, $docnum);

    if ($sform{'doc'}) {	
	$docnum = $sform{'doc'};
	$docnum =~ s|\D||g;
	$search = "(concept (doc r=$docnum))"; }
    elsif ($sform{'sum'}) {
	$docnum = $sform{'sum'};
	$docnum =~ s|\D||g;
	$search = "(sum sroot=$sform{'root'}/collections/summary n=$number_of_summary_sentences sep=~~~ $docnum)"; }
    elsif ($sform{'dump'}) {
	$docnum = $sform{'dump'};
	$docnum =~ s|\D||g;
	$search = "(dump title=0 hdr=1 $docnum)";
    }
    else {
	$search = $sform{'search'};
    }
    ## this mode means we should return a boolean search string
    if ($sform{'mode'} eq 'simple') {
	$search =~ s|\W| |g;
	$search =~ s|^\s+||g;
	$search =~ s|\s+$||g;
	$search =~ s|\s+| |g;
	@words = split(/\s/, $search);
	if ($#words <= 0) {
		$search = "(s @words)";
	}
	else {
		$search = "(c @words (. (& ";
		for $word (@words) {
		    $search .= "(sb ifstem=all $word) ";
		}
		$search .= ")))";
	}
    } else {
      ## checks for stemming by default mode
      if ($stem_by_default && ($search !~ /^\(/)) {
         $search = join('$ ', split(/\s+/, $search));
	 $search .= "\$";
	 $search =~ s/AND\$/AND/g;
	 $search =~ s/OR\$/OR/g;
	 $search =~ s/NOT\$/NOT/g;
      }
    }
    $search =~ s|\s+| |g;
    return $search;
}

## make any changes to the anchor that are necessary. i.e, add
## shttp attributes or something like that.
sub modifyAnchor {
    local($url) = @_;
	return ("<A HREF=\"$url\">");
}

sub addDumpOperator {
    local($file, $docnum, $db, $htmlroot) = @_;
    local($suffix) = $script_suffix;
    if (&underRoot($htmlroot, $file)) {
	return $file;
    } else {
	return "AT-${db}search$suffix?dump=d$docnum";
    }
}

## returns true if a $file is beneath $root directory
sub underRoot {
    local($root, $file) = @_;
    local($prefix);
    $root =~ s|\/$|| if ($root =~ /\/$/);
    $prefix = substr($file, 0, length($root));
    return 1 if ($prefix eq $root);
    return 0;
}


sub footer {
    local($aurl) = @_;
    if ($powered_by_excite) {
## NOTE:  according to the license agreement, you are not to
## remove this link if you are using a free version of EWS unless
## you have purchased a maintenance agreement.
	print <<EOF;
<br>
<center>
<a href="http://www.excite.com">
<img src="${aurl}pictures/$results_by_graphic" BORDER=0
ALT="Results by Excite"></a></center>
EOF
    ;
    }
}


## creates map and data files for all documents containing
## the url and title.  This is needed for notifier-enabled collections
sub createURLFiles {
    local($root, $db, %attr) = @_;
    local(%form);
    local($umapfile, $urledit, %mappings);

    $umapfile = "$root/collections/$db.usr" 
	if ($attr{'PublicHtml'}); 
    %mappings = 
	&ArchitextMap'getMappings($attr{'HtmlRoot'},
			       "$root/url.map",
			       $umapfile);
    $urledit = &ArchitextMap'generateURLEdit(%mappings);

    ## set up form for call to processResultLine
    $form{'db'} = $db;
    $hroot = $form{'hroot'} = $attr{'HtmlRoot'};
    $form{'thresh'} = 0.02;
    $form{'format'} = qq(%b %s %u <b>%t</b></A> %d <br>\n);
    $form{'num'} = 9999999;  ## list everything
    $form{'scorefun'} = "nothing";
    $form{'urledit'} = $urledit;

    ## these don't matter 
    $qbeimg = "<b>Q</b>";
    $sumimg = "(summary)";

    ## open map and index data files
    $croot = $attr{'CollectionRoot'};
    if (!open(IDX, ">$croot.url.idx")) {
        print "couldn't open auxiliary file for notification";
        exit -1;
    }
    if (!open(MAP, ">$croot.url.map")) {
        print "couldn't open auxiliary file for notification";
        exit -1;
    }

    ## call the search executable with -dump flag to get a list of all 
    ## documents in a form that can be passed to processResultLine
    $searchExecutable = $attr{'SearchExecutable'};
    ## convert for ports
    $searchExecutable = &main'convert_file_names($searchExecutable);
    open(DUMP, "$searchExecutable -R $root/collections/$db -dump|");
    while (<DUMP>) {
	chop;
	$newline = &processResultLine($_, $qbeimg, 
				      $sumimg, %form);
	if ($newline) {
	    ($url, $title) = &parseLine($newline);
            ## create real url
            ## if url is remote (http://...), do something different
            $sname = $attr{'ServerName'};
            $sport = $ENV{'SERVER_PORT'} || $attr{'ServerPort'};
            $url = "http://$sname:$sport$url"
		unless ($url !~ /^[\/\\]/);
	    ## get offset into IDX file
	    $pos = tell(IDX);
	    $ppos = pack("N", $pos);
	    $zero = pack("c", 0);
	    print IDX $url, $zero, $title, $zero;
	    print MAP $ppos;
	}
    }
    close(DUMP);
    if ($?) {
	print "couldn't get url list\n";
	exit -1;
    }    
    close(IDX);
    close(MAP);
}

## parses a result line and returns the url and title
sub parseLine {
    local($line) = @_;
    local($url, $title);
    @actions = split(/<A /, $line);
    foreach $action (@actions) {
        ## find action tag with wanted url and title, and extract
	if ($action =~ m|architext=result.*HREF="([^"]*)"[^>]*>(.*)</A>|i) {
            $url = $1;
            $title = $2;
            ## de-html'ize
            $title =~ s/<[^>]*>//g;
            last;
        }
    }
    ($url, $title);
}


1;





