## Architext perl library
## Copyright (c) 1996 Excite, Inc.

require 'ctime.pl';

package Architext;
require 'afeatures.pl'; 

######################################################
##         Notifier related functions               ##
######################################################

## is notifier enabled
sub notifyMode {
    return $notifier_on;
}

## returns associative array of published collections
sub pubList {
    local($dir) = @_;
    local(%pubs, @pub);
    opendir(PUB, $dir);
    @pub = grep(/\.pub$/, readdir(PUB));
    if ($#pub > -1) {
	for (@pub) {
	    s|\.pub||;
	    $pubs{$_} = 1;
	}
    }

    %pubs;
}

## returns the bit of HTML to denote a published collection
sub notifyTag {
    local($url) = @_;
    return "<img src=\"${url}pictures/$notify_icon\">";
}

sub notifyBlankTag {
    local($url) = @_;
    return "<img src=\"${url}pictures/$notify_blank\">";
}
 

######################################################
##       End of notifier related functions          ##
######################################################

sub inlineSummaryMode {
    return $inline_summaries;
}

sub externalSitesMode {
    return $external_sites;
}

sub numSumSent {
    return $number_of_summary_sentences;
}

sub backlinkMode {
    return $backlink_mode;
}

sub excitedAd {
    return $excited_ad;
}

sub scriptSuffix {
    return $script_suffix;
}

## allows for crypt not being implemented in NT perl
sub safeCrypt {
    local($plain, $salt) = @_;
    $plain =~ s/\\/\\\\/g;
    $plain =~ s/\@/\\\@/g;
    $plain =~ s/\$/\\\$/g;
    $salt =~ s/\\/\\\\/g;
    $salt =~ s/\@/\\\@/g;
    $salt =~ s/\$/\\\$/g;
    local($val) = eval "crypt(\"$plain\", \"$salt\");";
    $val || $plain;
}

## changes the password in the appropriate configuration file
sub updatePassword {
    local($root, $password, $db) = @_;
    local($conffile) = "$root/Architext.conf";
    local($pass);
    $password = &safeCrypt($password, $password) if $password;
    $conffile = "$root/collections/$db.conf" if $db;
    $oldfile = "$conffile.old";
    rename($conffile, $oldfile);
    open(OLDCONF, "$oldfile");
    open(CONFFILE, ">$conffile");
    while (<OLDCONF>) {
	print CONFFILE $_ unless ($_ =~ /Password/);
	if ($password) {
	    print CONFFILE "Password $password\n" if ($past == 2);
	}
	$past++;
    }
    close(CONFFILE);
    close(OLDCONF);
    unlink($oldfile);
}

sub exciteBanner {
    return $excite_banner;
}

sub searchButton {
    return $search_button;
}

sub dualSearchButton {
    return $dualsearch_button;
}

sub queryBanner {
    return $query_banner;
}

sub adminBanner {
    return $admin_banner;
}

## centralised mechanism for setting debug in main scripts.
sub debugMode {
    return $debugmode;
}

## are we logging searches
sub logMode {
    return $log_searches;
}

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

sub productVersion {
    return $productVersion;
}

sub newsURL {
    return $news_url;
}
				
sub remoteScriptName {
    return $remoteScriptName;
}

sub additionalOptions {
    local($filter_pdf) = @_;
    if ($a_acro) {
       print <<EOF;
<INPUT TYPE="checkbox" NAME="IndexFilterPDF" VALUE="PDF" $filter_pdf>
Adobe PDF Files (filenames with a <b>.pdf</b> suffix)<br>

EOF
;
    } 
}

sub remoteMode {
    ($root) = @_;
    return $remote if ($remote eq 'yes');
    return "" if ($remote eq 'no');
    if (-e "$root/.remote") {
	$remote = 'yes';
	return $remote;
    } else {
	$remote = 'no';
    }
    return "";
}

sub checkForIndex {
    local(%opt) = @_;
    if (! -e "$opt{'root'}.dat") {
	print "<p><h1>Error: No Index to query on.</h1>\n";
	print "<p>Apparently, there is no index available for this\n";
	print "collection, so queries cannot be made at this time.";
	exit(0);
    }
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

sub warningIcon {
    local($url) = @_;
    return "<img src=\"${url}pictures/$warning_icon\">";
}

sub errorIcon {
    local($url) = @_;
    return "<img src=\"${url}pictures/$error_icon\">";
}



## prints a legend describing the meaning of the colored
## balls and the summarize and qbe icons
sub printLegend {
    local(%opt) = @_;
    if ($show_legend) {
	if ($graphic_relevance_mode || 
	    $query_by_example_mode || 
	    $summary_mode) {
	    print "\n<hr>\n<b>Legend:</b><ul>\n";
	}
	if ($graphic_relevance_mode) {
	        print <<EOF;
<img border=0 src="$opt{'ahome'}pictures/$balls{'1'}"> Highly Relevant
<br><img border=0 src="$opt{'ahome'}pictures/$balls{'2'}"> Probably Relevant
<br><img border=0 src="$opt{'ahome'}pictures/$balls{'3'}"> Possibly Relevant
EOF
;
        }
        if ($subject_group_mode) {
        if ($balls{'qbe'}) {
            print <<EOF;
<br><img border=0 src="$opt{'ahome'}pictures/$balls{'qbe'}">
EOF
    ;
        } else {
	    print "<br><br><b>Q</b>: ";
        }
	print "Query By Example.  Find similar documents.\n";
    }
	if ($summary_mode) {
	if ($balls{'sum'}) {
	    print <<EOF;
<br><img border=0 src="$opt{'ahome'}pictures/$balls{'sum'}">
EOF
;
        } else {
            print "<br><b>S</b>: ";
	}
        print "Summarize.  Generate a short summary of the document.\n";

    }
    
        print "\n</ul><hr>" if ($graphic_relevance_mode || 
				$subject_group_mode || 
				$summary_mode);
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

sub setFilterString {
    local($filterstring) = @_;
    local($commas);
    return $filterstring if ($filterstring =~ /Only/);
    return $filterstring if ($filterstring =~ /and/i);
    $filterstring =~ s/^HTML/HTML, /;
    $filterstring =~ s/TEXT/Text, /;
    $filterstring =~ s/PDF/Adobe PDF, /;
    $filterstring =~ s/CUST/Custom Rules, /;
    $filterstring =~ s/,[^,]*$//g;
    $commas = $filterstring;
    $commas =~ s/[^,]//g;
    if (length($commas) > 1) {
	$filterstring =~ s/([^,]*)$/ and $1/;
    }
    if (length($commas) == 1) {
	$filterstring =~ s/,/ and/;
    }
    return "$filterstring files.";
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
    local($queryprog, $configfile, $query) = @_;
    local(*QUERY, *QUERY_ERR, $errstr, @queryresult);
    local($results);
    ## Make sure all the files are in place.
    if (!$queryprog || ! -x $queryprog) {
	&log_error("query program '$queryprog' does not exist " .
		   "or is not executable");
	return &html_errorstr("Cannot run query program");
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

    ## Should we do a default concept-based query?
    if ($query !~ /^\(/) {
	$query = "(concept $query)";
    }

    &execSubprocess(*QUERY, *QUERY_ERR, $queryprog, "-C", $configfile,
		    "-q", $query);
    
    
    
    ## Accumulate the results.
    while (<QUERY>) {
	chop;
	$results = 1 if /\S/;
	push(@queryresult, $_);
    }

    ## Errors to $errorstr.
    while (<QUERY_ERR>) {
	$errstr .= $_;
    }

    if (!$results && !$errstr) {
	$errstr =  "<p><b>No documents found.</b>";
    }

    ##ECO -- specialize message if all words were stopped
    $errstr = "<p><b>Error:</b> All your search words were considered too commonplace. (e.g. <i>a</i>, <i>and</i>, or <i>the</i>)  Please try again using less common words." if ($errstr =~ /All query words were stemmed/);
    $errstr = "success" unless $errstr;
    $errstr = "success" if ($errstr =~ /^ld\.so/); ##ignore runtime ld warnings
    $errstr = "summary" 
	if (($errstr eq "success") && ($query =~ /^\(sum.+\d+\)/));
    $errstr = "dump" 
	if (($errstr eq "success") && ($query =~ /^\(dump.+\d+\)/));
    return ($errstr, @queryresult);
}
## simply outputs the summary on to the page with paragraph breaks
## between pages.  optionally truncates the summary to a certain
## amount of bytes if that has been specified
sub SummaryOutput {
    local(*query) = @_;
    local($line, $total_length, $line_length);
    print "<h1> Summary </h1><p>\n";
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

## This subroutine takes the output from MakeQuery and HTMLizes it
## into a nice list. It takes a few options, described below.
sub HtmlList {
    local(*query, %opt) = @_;
    local($num, $score, $title, $path);
    local($format, $urledit, $prefix, $postfix, $numtoshow, $scorefun);
    local($str, $thresh, $shown, $max);
    local($qbe, $sum, $ball, $ballsrc, $qbeimg, $sumimg);
    local($result_line);

    ## this bit of code figures out whether to use icons or
    ## text for the summary and qbe URLs
    if ($balls{'qbe'}) {
	$qbeimg = 
	    qq(<img border=0 src="$opt{'ahome'}pictures/$balls{'qbe'}">);
    } else {
	$qbeimg = "<b>Q</b>";
    }
    if ($balls{'sum'}) {
	$sumimg = 
	    qq(<img border=0 src="$opt{'ahome'}pictures/$balls{'sum'}">);
    } else {
	$sumimg = "<b>S</b>";
    }

    ## The format string used to print the URL. Kindof like printf,
    ## see below for the format codes.
    $format = $opt{'format'} ? $opt{'format'} :
	qq(<br> %b %s %q %d %u %t</A>\n);

    ## Some perl code to transform a filename to a URL. The URL is in
    ## $_. A likely choice would be something like 
    ## 's|^/usr/local/www/html/|http:/|'.
    $urledit = $opt{'urledit'};	

    ## The number of documents to show.
    $numtoshow = $opt{'num'} ? $opt{'num'} : $max_docs_to_return;

    ## The scoring function. See below for details.
    $scorefun  = $opt{'scorefun'} ? $opt{'scorefun'} : "nothing";

    ## A threshhold for displaying results.
    $thresh = $opt{'thresh'} ? $opt{'thresh'} : 0.02;

    print "\n<ul>\n";

    $shown = 0;
    $max = 0;
    for $line (@query) {
	($num, $score, $ball, $url, $title) = split(/\t/, $line);
	next unless ($line =~ /\S/);
	$path = $url;
	if ($title =~ /No title/) {
	    $url =~ /\/?([^\/]+)$/;
	    $title = "$1 ";
	}
	if (! $title) {
	    $title = $url;
	    $title =~ /\/?([^\/]+)$/;
	    ## when the html file has no title, or if it is a text file,
	    ## we just want to print out the filename (minus the path)
	    $title = "$1 ";
	}
	last if ($shown++ >= $numtoshow);

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
	last if ($score < $max*$thresh);

	$url = &addDumpOperator($url, $num, $opt{'db'}, $opt{'hroot'})
	    if (! $restrict_beneath_document_root);

	## eval the URL.
	if ($urledit) {
	    eval '$_=$url;' . $urledit;
	    $url = $_ unless $@;
	}

	$url = &modifyAnchor($url);

	##calculate summary and QBE URLs
	if ($query_by_example_mode) {
	    $qbe = "<A HREF=\"AT-$opt{'db'}search$script_suffix?doc=d$num\">$qbeimg</A>"; 
	}
	if ($summary_mode) {
	    $sum = "<A HREF=\"AT-$opt{'db'}search$script_suffix?sum=d$num\">$sumimg</A>";
	}
	$ballsrc = 
	    "<img border=0 src=\"$opt{'ahome'}pictures/$balls{$ball}\">";

	$ballsrc = "<li>" unless ($graphic_relevance_mode);

	$result_line = &formatExpand($format, 'n', $num, 't', $title, 'u', 
				     $url, 's', $score, 'q', $qbe, 'd', $sum, 
				     'b', $ballsrc);
        if ($customize_result_list) {
	    $qbe = "(empty)" unless $qbe;
	    $sum = "(empty)" unless $sum;
	    $result_line = 
		&customize_result_list_line($opt{'db'}, $path, 
					    $opt{'hroot'}, $ballsrc, 
					    $score, $qbe, $sum, 
					    $title, $result_line);
	}
	print $result_line;
    }
	print "\n</ul>\n";
}

## collects the document numbers and relevance scores
## into a form to be used for auto subject grouping
sub PrepareGather {
    local(*query, %opt) = @_;
    local($line, $title, $order);

    $name = $opt{'name'};
    $name = "docs" unless $name;

    $order = 0;
    $args = "";
    for $line (@query) {
	($num, $score, $ball, $url, $title) = split(/\t/, $line);
	if (($num !~ /\D/) && ($ball !~ /\D/)) {
	    $args .= "$num|$ball|$order ";
	    $order++;
	}
    }
    chop($args);		# Kill trailing ' '

    print qq(<FORM ACTION="AT-$opt{'db'}gather$script_suffix" METHOD="POST">\n);
    print qq(<INPUT TYPE="submit" NAME="Group By Subject" VALUE="Group By Subject">\n);
    print qq(<INPUT TYPE="hidden" SIZE=1 NAME="$name" VALUE="$args">);
    print qq(</FORM>\n);
}



sub MakeGather {
    local($queryprog, $configfile, $docstr, %opt) = @_;
    local(*QUERY, *QUERY_ERR, $errstr, @queryresult, @docs, @udocs);
    local($groupnum, %groupwords, %grouparts, %titles, %colors, $num, $query);
    local(%groupcount);
    local(%rels);
    local(%newgrouparts);
    local(%urls, %second_urls);
    local(%second_grouparts, %second_titles);
    local($pastbest, $totalarts);		
    local($gopen_ball, $ballsrc, $ndoc, $bdoc, $adoc, $qbe, $sum);
    local($qbeimg, $sumimg);
    local($result_line, $path);

    ## this bit of code figures out whether to use icons or
    ## text for the summary and qbe URLs
    if ($balls{'qbe'}) {
	$qbeimg = 
	    qq(<img border=0 src="$opt{'ahome'}pictures/$balls{'qbe'}">);
    } else {
	$qbeimg = "<b>Q</b>";
    }
    if ($balls{'sum'}) {
	$sumimg = 
	    qq(<img border=0 src="$opt{'ahome'}pictures/$balls{'sum'}">);
    } else {
	$sumimg = "<b>S</b>";
    }

    ## Make sure all the files are in place.
    if (!$queryprog || ! -x $queryprog) {
	&log_error("query program '$queryprog' does not exist " .
		   "or is not executable");
	return &html_errorstr("Cannot run query program");
    }

    if (!$configfile || ! -r $configfile) {
	&log_error("cannot find config file '$configfile'");
	return &html_errorstr("Cannot find configuration file");
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

    $query = $opt{'gather_cmd'};
    $query = 
	"(g $gather_options g=$number_of_subject_groups (. DOCS))" 
	    unless $query;
    $query =~ s/DOCS/@docs/g;

    if ($graphic_relevance_mode) {
	$gopen_ball =  
	    "<img border=0 src=\"$opt{'ahome'}pictures/$balls{'0'}\">";
    } else {
	$gopen_ball = "<li>";
    }

    $format_gopen = $opt{'format_gopen'} ? $opt{'format_gopen'} :
	"%b <i>Group %g:</i> <b>%w</b><ul>\n";
    $format_gclose = $opt{'format_gclose'} ? $opt{'format_gclose'} :
	"</ul>\n";
    $format_gentry = $opt{'format_gentry'} ? $opt{'format_gentry'} :
	"%b %q %s %u %t</a><br>\n";

    $urledit = $opt{'urledit'};
    
    &execSubprocess(*QUERY, *QUERY_ERR, $queryprog, "-C", $configfile,
		    "-q", $query);

    $groupnum = 0;
    $totalarts = 0;
    while (<QUERY>) {
	chop;
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
	    $second_titles{$1} = $3;
	    $second_tkey = $1;
	    $second_grouparts{$groupnum} .= "$1 ";
	    if ($second_titles{$second_tkey} =~ /No title/) {
		$second_urls{$second_tkey} =~ /\/?([^\/]+)$/;
		$second_titles{$second_tkey} = "$1 ";
	    }
	    if (! $second_titles{$second_tkey}) {
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
	    $titles{$1} = $3;
	    $tkey = $1;
	    $grouparts{$groupnum} .= "$1 ";
	    if ($titles{$tkey} =~ /No title/) {
		$urls{$tkey} =~ /\/?([^\/]+)$/;
		$titles{$tkey} = "$1 ";
	    }
	    if (! $titles{$tkey}) {
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
	
    
    ## Errors to $errorstr.
    while (<QUERY_ERR>) {
	$errstr .= $_;
    }

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

	    $url = &addDumpOperator($url, $num, $opt{'db'}, $opt{'hroot'})
		if (! $restrict_beneath_document_root);

	    if ($urledit) {
		eval '$_=$url;' . $urledit;
		$url = $_ unless $@;
	    }

	    $url = &modifyAnchor($url);
	    ## figure out the appropriate colored ball to put here
	    $ballsrc = 
		"<img border=0 src=\"$opt{'ahome'}pictures/$balls{$colors{$num}}\">";
	    $ballsrc = "<li>" unless ($graphic_relevance_mode);

	    ##calculate summary and QBE URLs
	    if ($query_by_example_mode) {
		$qbe = "<A HREF=\"AT-$opt{'db'}search$script_suffix?doc=d$num\">$qbeimg</A>";
	    }
	    if ($summary_mode) {
		$sum = "<A HREF=\"AT-$opt{'db'}search$script_suffix?sum=d$num\">$sumimg</A>";
	    }

	    $result_line = &formatExpand($format_gentry,
					 'g', $groupnum,
					 'n', $num,
					 'w', $groupwords{$g},
					 't', $titles{$num},
					 'u', $url,
					 'q', $qbe,
					 's', $sum,
					 'b', $ballsrc);
	    if ($customize_result_list) {
		$qbe = "(empty)" unless $qbe;
		$sum = "(empty)" unless $sum;
		$result_line = &customize_grouping_line($opt{'db'}, $path, 
							$opt{'hroot'},
							$ballsrc,
							$qbe, $sum,
							$titles{$num},
							$result_line);
	    }
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
	$form{&unhttpize($key)} = &unhttpize($val);
    }

    %form;
}

## This function reads arguments from a GET method, a POST method, or
## the command line (the latter for testing purposes). It then unpacks
## them and returns the associative array.
sub readFormArgs {
    local($args, $len);

    $args = $ENV{'QUERY_STRING'};
    if (!$args) {
	$len = $ENV{'CONTENT_LENGTH'};
	if ($len && ($ENV{'REQUEST_METHOD'} eq 'POST')) {
	    if (read(STDIN, $args, $len) != $len) { die "Couldn't read POST"; }
	}
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
    local($path, $title, $head, $nohead) = @_;
    $head = $title unless $head;
    &printHttpHeader unless $nohead;
    print "<head><title> $title </title></head><BODY BGCOLOR=\"#FFFFFF\" TEXT=\"#000000\" LINK=\"#FF0000\" ALINK=\"#0000FF\">\n";
    &showForm() if $debugmode;
    print <<EOP;
<h2> <center><img src="${path}pictures/$admin_banner"><P>$head</center></h2>
EOP
    ;
}


## Prints out the standard Architext header.
sub printInstallHeader {
    local($path, $title, $head, $no_head) = @_;
    $head = $title unless $head;
    &printHttpHeader unless $no_head;
    print "<head><title> $title </title></head><BODY BGCOLOR=\"#FFFFFF\" TEXT=\"#000000\" LINK=\"#FF0000\" ALINK=\"#0000FF\">\n";
    &showForm() if $debugmode; 
    print <<EOP;
<h2> <img src="${path}pictures/$install_banner"><P>$head</h2>
EOP
    ;
}


sub printHttpHeader {
    print "Content-type: text/html\n\n";
}

sub printDoc {
	local($fileName, $picturePath) = @_;
	&printHttpHeader;
	if (! open(FILE, "$fileName")) {
		&Architext'exitError($atextUrl, "Cannot open $fileName because $!."); 
	}
	else {
		undef $/;
		local ($lines) = <FILE>;
		$lines =~ s/SRC="(.*)"/SRC="$picturePath$1"/gi;
		$lines =~ s/HREF="AT-(.*)"/HREF="${picturePath}AT-$1"/gi;
		print $lines;
		close(FILE);
	}
}

## Prints out the Architext header.
sub Copyright {
    local($path) = @_;
    if ($remote eq 'yes') {
	$path = $help_path;
    }
    print <<EOC;
<HR>
Confused?  Try the <A HREF="${path}AT-help.html">online help.</a>  Or click on
any hyper-links for definitions.
<HR><I>These scripts and forms are copyright
<A HREF="http://corp.excite.com/">Excite, Inc.</A>, &copy 1996 </I>
EOC
    ;
}

## Prints an input line for a form.
sub printInputLine {
    local($name, $text, $db) = @_;
    local($val);
    local($size, $path);
    $text = $name unless $text;
    $val = eval "\$attr{$name}";
    $val = "$attr{'ArchitextRoot'}/$db" if $db;
    $size=40;
    $size = (length($val) +10) unless ((length($val) +10) < 40);
    $path = $attr{'ArchitextURL'};
    $path = $help_path if ($remote eq 'yes');
    print <<EOF;
<LI> <a href="${path}AT-helpdoc.html#$text">$text:</a> 
<INPUT NAME="$name" VALUE="$val" SIZE=$size><P>
EOF
    ;
}

sub queryError {
    local($errstr) = @_;
    print "<h2> Error! </h2>\n" unless 
	(($errstr eq '<p><b>No documents found.</b>') ||
	 ($errstr =~ /too commonplace/));
    print $errstr;
    exit(0);
}

## Print an error message, print our copyright, and exit.
sub exitError {
    local($url, $message, $password) = @_;
    local($path);
    $path = &errorIcon($url);
    print "<H2> ${path} $message</H2>\n";
    print <<EOF;
<p><FORM ACTION="AT-admin$script_suffix" METHOD=POST>
<INPUT TYPE="submit" NAME="Admin" VALUE="Main Admin Page">
Go back to the main administration page.
$password
</FORM>
EOF
    ;
    &Architext'Copyright($url);
    exit 0;
}

## A regular exitError, but with file information too.
sub exitFileError {
    local($url, $file, $message) = @_;
    &exitError($url, "The specified file '$file' $message");
}

## Prints a line item for a form.
sub printLineItem {
    local($url, $name, $text) = @_;
    $url = $help_path if ($remote eq 'yes');
    $text = "(Nothing Specified)" unless $text;
    print qq(<li> <a href="${url}AT-helpdoc.html#$name">$name:</a> $text\n);
}

sub showForm {
    local($key);
    print "<h1>Debug Mode</h1><p>\n";
    print "<ul>\n";
    foreach $key (keys(%dform)) {
	print "<li> $key: $dform{$key}\n"; }
    print "</ul>\n";
}

## tells the user what his query was on the result page, if
## appropriate.
sub showSearchString {
    local(%sform) = @_;
    local($search);
    ## don't do anything if it was an ASG.
    if (! $sform{'docs'}) {
	$search = $sform{'search'};
	$search =~ s|\W| |g;
	##print "<h2>Query Results</h2>" unless ($sform{'sum'} ||
	##				       $sform{'dump'});
	print "\n<p>Your search was: <b>$search</b>\n"
	    unless (($sform{'doc'}) || ($sform{'sum'}) ||
		    ($sform{'dump'}));
	print "\n<p>Your search was a <b>Query By Example</b>\n" 
	    if $sform{'doc'};
	print "<br>";
	
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
	$search = "(concept (doc $docnum))"; }
    elsif ($sform{'sum'}) {
	$docnum = $sform{'sum'};
	$docnum =~ s|\D||g;
	$search = "(sum n=$number_of_summary_sentences sep=~~~ $docnum)"; }
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
    }
    $search =~ s|\s+| |g;
    return $search;
}

## this routine verifies that the password passed in is correct.
## if incorrect or missing, it presents the user with an
## access page.
sub password {
    local($path, $scriptname, $password, %form) = @_;
    local($guess, $db);
    local($reverse) = reverse($password);
    local($size) = length($password) + 10;
    $size = 30 if ($size > 30);
    if ($form{'password'}) {
	$guess = $form{'password'};
	$postpass = 
	    "<INPUT TYPE=\"hidden\" NAME=\"$reverse\" VALUE=\"$password\">" 
		if (&safeCrypt($guess, $password) eq $password);
	return $reverse if (&safeCrypt($guess, $password) eq $password);
    }
    if ($form{$reverse}) {
	$guess = $form{$reverse};
	$postpass = 
	    "<INPUT TYPE=\"hidden\" NAME=\"$reverse\" VALUE=\"$password\">" 
		if ($password eq $guess);
	return $reverse if ($guess eq $password);
    }
    &Architext'printHeader($path, "Password Required");
    $db .= "<INPUT TYPE=\"hidden\" NAME=db VALUE=$form{'db'}>" if
	$form{'db'};
    print <<EOF
<p><b> Access restricted for $scriptname.</b><p>
<FORM ACTION="$scriptname" METHOD=POST>
<p> Enter password here: 
<INPUT NAME="password" TYPE="Password" SIZE=$size>
<INPUT TYPE="submit" VALUE="OK">
$db
</FORM>
EOF
;
    &Architext'Copyright($path);
    exit(0);

}

## make any changes to the anchor that are necessary. i.e, add
## shttp attributes or something like that.
sub modifyAnchor {
    local($url) = @_;
    if ($url =~ /search\$script_suffix\?dump=d/) {
	return ("<A HREF=\"$url\">");
    } else {
	return ("<A HREF=\"/$url\">");
    }
}

sub addDumpOperator {
    local($file, $docnum, $db, $htmlroot) = @_;
    if (&underRoot($htmlroot, $file)) {
	return $file;
    } else {
	return "AT-${db}search$script_suffix?dump=d$docnum";
    }
}

## return the status information for a particular collection
sub getStatusString {
    local($root, $db, $configroot, $url, $cgi, $getpass) = @_;
    local($exist, $progress, $none, $error, $page, $move);
    local($warn) = &warningIcon($url);
    $exist = "Index built." if (-e "$root/collections/$db.last");
    $progress = "Indexing in progress." if (-e "$root/collections/$db.pid");
    $error = "${warn}Indexing error." if (-e "$root/collections/$db.err");
    if ((! -e "$root/collections/$db.last") && 
	(! -e "$root/collections/$db.pid")) {
	$none = "No index.";
    }
    if ((-e "$configroot/AT-${db}query.html") 
            && (-e "$cgi/AT-${db}search$script_suffix")) {
	    $page = "<a href=\"${url}AT-${db}query.html\">Search page</a> available.";
	}
    if ((-e "$configroot/AT-${db}query.html") && (-e "$configroot/AT-${db}search$script_suffix") && (! -e "$cgi/AT-${db}search$script_suffix")) {
	$mover = "moveinfo=moveinfo&dbname=$db";
	$mover = "?$mover" unless $getpass;
	$mover = "&$mover" if $getpass;
        $move = "Search page generated, but <a href=\"AT-generate$script_suffix$getpass$mover\">scripts not yet moved</a>."; 
}
    return "$exist $progress $error $none $page $move";
}


sub printStatus {
    local($db, $root, $configroot, $url, $help, $collectionroot, $cgi, $getpass) = @_;
    local($warn) = &warningIcon($url);
    if ((-e "$configroot/AT-${db}query.html") &&
        (-e "$cgi/AT-${db}search$script_suffix")) {
	print qq(A <a href="${url}AT-${db}query.html">search page</a> has been generated.<br>\n);
    }
    if ((-e "$configroot/AT-${db}query.html") && (-e "$configroot/AT-${db}search$script_suffix") && (! -e "$cgi/AT-${db}search$script_suffix")) {
	$mover = "moveinfo=moveinfo&dbname=$db";
	$mover = "?$mover" unless $getpass;
	$mover = "&$mover" if $getpass;
	print <<EOF;
A search page was generated, but  
<a href="AT-generate$script_suffix$getpass$mover">the search scripts</a> 
need to be moved.<br>
EOF
    ;
    }
    if (-e "$root/collections/$db.last") {
	open(LAST, "$root/collections/$db.last");
	print "An indexing process successfully completed on ";
	print <LAST>;
	print ".<br>\n";
	close(LAST);
	open(SIZE, "$collectionroot.size");
	$size = <SIZE>;
	print "The corpus indexed was ${size}K in size.<br>\n" if $size;
    }
    if (-e "$root/collections/$db.pid") {
	print "Indexing is in progress for this collection.<br>\n";
    }
    if (-e "$root/collections/$db.err") {
	print "${warn}An error was encountered during the latest indexing run.  Check the log files for more information.<br>\n";
    }
    if (! -e "$root/collections/$db.last") {
	print "No index has been built for this collection.<br>\n";
    }
    if ((-e "$root/collections/$db.pub") && (&notifyMode())) {
	print qq(This collection is participating in the excite <a href="${help}AT-helpdoc.html#Notifier">notifier</a>.<br>\n);
    }
    
}

## returns true if flag to index user directories is enabled
sub indexUserDirs {
    return $index_user_dirs;
}

sub NSOn {
    $no_stemming_mode; 
}

## returns true if a $file is beneath a directory listed in the
## %mappings associative array
sub underRoot {
    local($file, $port, %mappings) = @_;
    local($prefix, $root);
    for (keys %mappings) {
	$root = $_;
	$root =~ s|\/$|| if ($root =~ /\/$/);
	$prefix = substr($file, 0, length($root));
	if ($port eq 'NT') {
	    $prefix =~ tr/A-Z/a-z/;
	    $root =~ tr/A-Z/a-z/;
	}
	return 1 if ($prefix eq $root);
    }
    return 0;
}


## prints a simple description of a collection's attributes
sub collectionCharacteristics {
    local($db, $helppath, %attr) = @_;
    local($url) = $attr{'ArchitextURL'};
    print "<UL>\n";
    &printLineItem($url,'IndexExecutable',
			     $attr{'IndexExecutable'})
	if &debugMode();       
    &printLineItem($url,'SearchExecutable',
			     $attr{'SearchExecutable'})
	if &debugMode();	
    &printLineItem($url,'StemTable',$attr{'StemTable'})
	if &debugMode();	
    &printLineItem($url,'StopTable',$attr{'StopTable'})
	if &debugMode();	
    &printLineItem($url,'CollectionInfo', $attr{'CollectionInfo'})
	if &debugMode();
    &printLineItem($url,'CollectionIndex',
		   $attr{'CollectionIndex'});
    if ($attr{'CollectionContents'} =~ /^\+/) {
	$attr{'CollectionContents'} =~ s/^\+//;
	print <<EOF;
<li> <a href="${helppath}AT-helpdoc.html#CollectionContents">
CollectionContents:</a> Index the files listed in 
'$attr{'CollectionContents'}'.
EOF
    ;
    } else {
	$files = join(", ", split(/[,;\s]+/, $attr{'CollectionContents'}))
	    if $attr{'CollectionContents'};
	$files = "'$files'" if $files;
	$flist = "the file list '$attr{'FileList'}'" if $attr{'FileList'};
	$userd = "'~user/$attr{'PublicHtml'}' directories" 
	    if $attr{'PublicHtml'};
	
	$content_string = join(",", $files, $flist, $userd);
	$content_string =~ s/,+/,/g;
	$content_string =~ s/,$//g;
	$content_string =~ s/^,//g;
	$content_string =~ s/,/, and the files in /g;
	print <<EOF;
<li> <a href="${helppath}AT-helpdoc.html#CollectionContents">
CollectionContents:</a> Index the files in $content_string using 
these rules:<ul>
EOF
    ;
    $filterstring = &setFilterString($attr{'IndexFilter'});
    &printLineItem($url,'IndexFilter',
		   $filterstring);
    &printLineItem($url,'Custom Filter File',
		   $attr{'ExclusionRules'});
    print "</ul>";
    }
    &printLineItem($url,'IndexingContact',
		   $attr{'AdminMail'});
    print "</UL>\n";

}


1;





