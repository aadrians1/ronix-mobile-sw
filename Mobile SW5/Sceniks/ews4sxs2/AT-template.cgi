
$myself = $aurl . '/AT-' . $db . 'search.cgi';


if ($form{'notifySearchPage'}) {

    print qq(<html><head><title>EWS Querying</title></head>);
    print qq(<body BGCOLOR="#FFFFFF" TEXT="#000000" LINK="#FF0000" ALINK="#0000FF"><h1> <img src="${aurl}pictures/AT-search_banner.gif"> </h1><p>);

    if (!open(QFORM, "$root/AT-query.html")) {
        print "<h1>Couldn't find $root/AT-query.html</h1>";
        print qq(<a href="$form{'notifyReturn'}">BACK</a>);
        exit(0);
    }
    while (<QFORM>) {
	s/CGI/$myself/;
	s/BUTTON/$aurl\/pictures\/AT-search_button.gif/;
	s/EXCITED/$aurl\/pictures\/AT-excited.gif/;
	s/DOC/$aurl\/AT-queryhelp.html/;
	s/QUERY/$form{'search'}/;
	print "$_\n" unless ((/___SEPARATOR___/) || $skip_radio || (/___END___/));
	$skip_radio = 0 if (/___END___/);
        if (/___SEPARATOR___/) {
  	  $skip_radio = 1;
          print qq(<INPUT TYPE="hidden" NAME="notifyReturn" VALUE="$form{'notifyReturn'}">);
        }
    }
    close(QFORM);
    print qq(</body></html>);
    exit(0);
}

## make NewSearch button point back to excite
if ($form{'notifyReturn'}) {
  $form{'sp'} = 'sp';
  if ($form{'notifyReturn'} eq '_back_') {
    $ENV{'HTTP_REFERER'} = $myself . '?notifySearchPage=yes';
  }
  else {
    $ENV{'HTTP_REFERER'} = $form{'notifyReturn'};
  }
}

___SEPARATOR___

$form{'root'} = $root;
$search = &ArchitextQuery'setSearchString(%form);
$searchtype = &ArchitextQuery'getSearchMode(%form);

## put necessary additional information into %form
$form{'aurl'} = $aurl;
$form{'db'} = $db;
$form{'index'} = $index;
$form{'hroot'} = $hroot;
$form{'binary'} = $binary;
$form{'urledit'} = $urledit;
$form{'searchpage'} = $ENV{'HTTP_REFERER'} if ($form{'sp'});
$form{'docs'} = '1' unless $form{'docs'};
$form{'psearch'} = $form{'psearch'} || $form{'search'};
$form{'search'} = $search;

$errstr = 'success';
## This call checks to make sure that an index has been built for 
## this collection.  Also checks if we should use new query syntax
$form{'newquery'} = &ArchitextQuery'checkForIndex(%form);

if ($searchtype eq 'confidence') {
    ## Perform the query. This function doesn't print anything. 
    ##Later commands will display the results.
    ($errstr, @query_results) = &ArchitextQuery'MakeQuery(%form);
    $docs = &ArchitextQuery'PrepareGather(*query_results);
    $form{'docs'} = $docs;
    &ArchitextQuery'showSearchMode($searchtype, %form) 
	unless (($errstr eq 'summary') || ($errstr eq 'dump'));
    &ArchitextQuery'showSearchString(%form) 
	unless (($errstr eq 'summary') || ($errstr eq 'dump'));
    &ArchitextQuery'HtmlList(*query_results, %form) if ($errstr eq 'success');
} else {
    ## subject group query
    &ArchitextQuery'showSearchMode($searchtype, %form);
    &ArchitextQuery'showSearchString(%form, 'gather', 'gather');
    $errstr = &ArchitextQuery'MakeGather(%form);

}

if ($errstr eq 'summary') {
    	&ArchitextQuery'SummaryOutput($form{'stitle'} || '*',
				      $form{'surl'} || '*',
				      *query_results);
} elsif ($errstr eq 'dump') {
    	&ArchitextQuery'DocumentOutput(*query_results);
} else {
    	print &ArchitextQuery'queryError($errstr) 
	    unless ($errstr eq 'success');
}

&ArchitextQuery'footer($aurl) if ($errstr eq 'success');




