#!/usr/local/www/scenix.com/ews4sxs2/perl

$root = "/usr/local/www/scenix.com/ews4sxs2";
unshift(@INC, "$root/perllib");
require 'architext_query.pl';
require 'ctime.pl';
$aurl = "/Excite/";
$db = "vp";
$index = "/usr/local/www/scenix.com/ews4sxs2/collections/vp";
$hroot = "/usr/local/www/scenix.com";
$binary = "/usr/local/www/scenix.com/ews4sxs2/architextSearch";
$urledit = 's|[\\\/]usr[\\\/]local[\\\/]www[\\\/]scenix.com[\\\/]|/|; ';

%form = &ArchitextQuery'readFormArgs;
&ArchitextQuery'directQuery($form{'search'} || '(no search)',
	$form{'mode'} || 'concept', $db, $form{'source'} || 'local', $form{'backlink'} || '*', $form{'bltext'} || '*');
print "Content-type: text/html\n\n";

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

print <<EOF;
<html>
<head>
<title>Scenix Semiconductor, Inc. - Virtual Peripherals</title>
</head>

<!-- macro virtual_header start -->

<script language="JavaScript">

       if (document.images) {            
       img1on = new Image();   img1on.src = "/gifs/home2.gif";  
       img2on = new Image();   img2on.src = "/gifs/search2.gif";
       img3on = new Image();   img3on.src = "/gifs/sitemap2.gif";
       img4on = new Image();   img4on.src = "/gifs/feedback2.gif";
       img1off = new Image();  img1off.src = "/gifs/home1.gif";
       img2off = new Image();  img2off.src = "/gifs/search1.gif";
       img3off = new Image();  img3off.src = "/gifs/sitemap1.gif";
       img4off = new Image();  img4off.src = "/gifs/feedback1.gif";
       }

    function imgOn(imgName) {
            if (document.images) {
                document[imgName].src = eval(imgName + "on.src");       
            }
    }

    function imgOff(imgName) {
            if (document.images) {
                document[imgName].src = eval(imgName + "off.src");        
            }
    }
// -->
</script>

<BODY BACKGROUND="/gifs/bg.gif" TEXT="#000000" LINK="#006699" VLINK="#006342" onLoad="defaultStatus=''">

<table border="0" cellpadding="0" cellspacing="0" width="630">
<tr>
<td width="115" align="center" valign="top"><a href="/index.html"><img src="/gifs/sxlogo.gif" width="78" height="71" alt="Scenix Logo" border="0"></a></td>
<td align="right" valign="top"><nobr><img src="/gifs/scenix.gif" width="269" height="28" alt="Scenix Banner" border="0"></nobr><a href="/index.html" onmouseover="imgOn('img1')" onmouseout="imgOff('img1')"><nobr><img src="/gifs/home1.gif" height="28" width="52" border="0" alt="Home" name="img1"></nobr></a><a href="/search/index.html" onmouseover="imgOn('img2')" onmouseout="imgOff('img2')"><nobr><img src="/gifs/search1.gif" height="28" width="52" border="0" alt="Search" name="img2"></nobr></a><a href="/search/sitemap.html" onmouseover="imgOn('img3')" onmouseout="imgOff('img3')"><nobr><img src="/gifs/sitemap1.gif" height="28" width="58" border="0" alt="Sitemap" name="img3"></nobr></a><a href="/virtual/feedback/index.html" onmouseover="imgOn('img4')" onmouseout="imgOff('img4')"><nobr><img src="/gifs/feedback1.gif" height="28" width="58" border="0" alt="Contact" name="img4"></nobr></a><br>
<p><nobr><img src="/gifs/virtual.gif" width="244" height="42" alt="Virtual Peripherals" border="0"><img src="/gifs/img.gif" width="228" height="42" border="0" alt="Circuit Board"></nobr></td>
</tr>

<tr>
<td align="center" valign="top" width="112">

<applet code="ime" codebase="/java" align="baseline" height="350" width="112">
<!--TAG GENERATOR: OpenCube - Applet Composer, (www.opencube.com)-->

<!--OpenCube Copyright Notice Parameter-->
<param name="Notice" value="Infinite Menus, Copyright (c) 1998, OpenCube Inc.">

<!--General / Default Settings-->
<param name="bgcolor" value="255,255,255">
<param name="onsbtext" value="Scenix Semiconductor, Inc.">
<param name="offsbtext" value="Cost Effective Microcontrollers">
<param name="bgxy" value="0,0">
<param name="font" value="Helvetica,Bold,11">
<param name="menutextcolor" value="8,0,2">
<param name="lrmargin" value="4">
<param name="halign" value="left">
<param name="menucolor" value="180,222,242">
<param name="menuoutlinecolor" value="0,0,0">
<param name="menuhlcolor" value="66,128,163">
<param name="menuhltextcolor" value="0,0,0">
<param name="loadwhere" value="_self">

<!--Specific Settings-->
<param name="imagefile0" value="/gifs/company1.gif">
<param name="imagexy0" value="0,10">
<param name="switchfile0" value="/gifs/company2.gif">
<param name="imagedesturl0" value="http://www.scenix.com/company/index.html">
<param name="imagefile1" value="/gifs/products1.gif">
<param name="imagexy1" value="0,40">
<param name="switchfile1" value="/gifs/products2.gif">
<param name="imagedesturl1" value="http://www.scenix.com/products/index.html">
<param name="imagefile2" value="/gifs/tools1.gif">
<param name="imagexy2" value="0,70">
<param name="switchfile2" value="/gifs/tools2.gif">
<param name="imagedesturl2" value="http://www.scenix.com/tools/index.html">
<param name="imagefile3" value="/gifs/virtual1.gif">
<param name="imagexy3" value="0,100">
<param name="switchfile3" value="/gifs/virtual2.gif">
<param name="imagedesturl3" value="http://www.scenix.com/virtual/index.html">
<param name="imagefile4" value="/gifs/news1.gif">
<param name="imagexy4" value="0,130">
<param name="switchfile4" value="/gifs/news2.gif">
<param name="imagedesturl4" value="http://www.scenix.com/news/index.html">
<param name="imagefile5" value="/gifs/support1.gif">
<param name="imagexy5" value="0,160">
<param name="switchfile5" value="/gifs/support2.gif">
<param name="imagedesturl5" value="http://www.scenix.com/support/index.html">
<param name="imagefile6" value="/gifs/partners1.gif">
<param name="imagexy6" value="0,190">
<param name="switchfile6" value="/gifs/partners2.gif">
<param name="imagedesturl6" value="http://www.scenix.com/partners/index.html">
<param name="imagefile7" value="/gifs/sales1.gif">
<param name="imagexy7" value="0,220">
<param name="switchfile7" value="/gifs/sales2.gif">
<param name="imagedesturl7" value="http://www.scenix.com/sales/index.html">
<param name="imagefile8" value="/gifs/jobs1.gif">
<param name="imagexy8" value="0,250">
<param name="switchfile8" value="/gifs/jobs2.gif">
<param name="imagedesturl8" value="http://www.scenix.com/jobs/index.html">
<param name="desc0-0" value="Background">
<param name="desturl0-0" value="http://www.scenix.com/company/background/index.html">
<param name="loadwhere0-0" value="_self">
<param name="desc0-1" value="FAQs">
<param name="desturl0-1" value="http://www.scenix.com/company/faq/index.html">
<param name="loadwhere0-1" value="_self">
<param name="desc0-2" value="Contact">
<param name="desturl0-2" value="http://www.scenix.com/company/contact/index.html">
<param name="loadwhere0-2" value="_self">
<param name="desc0-3" value="Directions">
<param name="desturl0-3" value="http://www.scenix.com/company/directions/index.html">
<param name="loadwhere0-3" value="_self">
<param name="desc1-0" value="Datasheets">
<param name="desturl1-0" value="http://www.scenix.com/products/datasheets/index.html">
<param name="loadwhere1-0" value="_self">
<param name="desc1-1" value="Manuals">
<param name="desturl1-1" value="http://www.scenix.com/support/manuals/index.html">
<param name="loadwhere1-1" value="_self">
<param name="desc1-2" value="Briefs">
<param name="desturl1-2" value="http://www.scenix.com/products/briefs/index.html">
<param name="loadwhere1-2" value="_self">
<param name="desc1-3" value="Quick Tour">
<param name="desturl1-3" value="http://www.scenix.com/products/quicktour/index.html">
<param name="loadwhere1-3" value="_self">
<param name="desc1-4" value="Feedback">
<param name="desturl1-4" value="http://www.scenix.com/products/feedback/index.html">
<param name="loadwhere1-4" value="_self">
<param name="desc3-0" value="Concept">
<param name="desturl3-0" value="http://www.scenix.com/virtual/wpapers/index.html">
<param name="loadwhere3-0" value="_self">
<param name="desc3-1" value="Modules">
<param name="desturl3-1" value="http://www.scenix.com/virtual/vp/index.html">
<param name="loadwhere3-1" value="_self">
<param name="desc3-2" value="App Notes">
<param name="desturl3-2" value="http://www.scenix.com/support/appnotes/index.html">
<param name="loadwhere3-2" value="_self">
<param name="desc4-0" value="Press">
<param name="desturl4-0" value="http://www.scenix.com/news/press/index.html">
<param name="loadwhere4-0" value="_self">
<param name="desc4-1" value="Articles">
<param name="desturl4-1" value="http://www.scenix.com/news/articles/index.html">
<param name="loadwhere4-1" value="_self">
<param name="desc4-2" value="Analysts Kit">
<param name="desturl4-2" value="http://www.scenix.com/news/analysts/index.html">
<param name="loadwhere4-2" value="_self">
<param name="desc4-3" value="Press Kit">
<param name="desturl4-3" value="http://www.scenix.com/news/presskit/index.html">
<param name="loadwhere4-3" value="_self">
<param name="desc5-0" value="App Notes">
<param name="desturl5-0" value="http://www.scenix.com/support/appnotes/index.html">
<param name="loadwhere5-0" value="_self">
<param name="desc5-1" value="Design Hints">
<param name="desturl5-1" value="http://www.scenix.com/support/hints/index.html">
<param name="loadwhere5-1" value="_self">
<param name="desc5-2" value="Specifications">
<param name="desturl5-2" value="http://www.scenix.com/support/specs/index.html">
<param name="loadwhere5-2" value="_self">
<param name="desc5-3" value="Errata">
<param name="desturl5-3" value="http://www.scenix.com/support/errata/index.html">
<param name="loadwhere5-3" value="_self">
<param name="desc5-4" value="Training">
<param name="desturl5-4" value="http://www.scenix.com/support/training/index.html">
<param name="loadwhere5-4" value="_self">
<param name="desc5-5" value="Newsgroups">
<param name="desturl5-5" value="http://www.scenix.com/support/bbs/index.html">
<param name="loadwhere5-5" value="_self">
<param name="desc5-6" value="Manuals">
<param name="desturl5-6" value="http://www.scenix.com/support/manuals/index.html">
<param name="loadwhere5-6" value="_self">
<param name="desc5-7" value="FAQs">
<param name="desturl5-7" value="http://www.scenix.com/support/faq/index.html">
<param name="loadwhere5-7" value="_self">
<param name="desc5-8" value="Feedback">
<param name="desturl5-8" value="http://www.scenix.com/support/box/index.html">
<param name="loadwhere5-8" value="_self">
<param name="desc5-9" value="Search">
<param name="desturl5-9" value="http://www.scenix.com/support/search/index.html">
<param name="loadwhere5-9" value="_self">
<param name="desc5-10" value="Links">
<param name="desturl5-10" value="http://www.scenix.com/support/links/index.html">
<param name="loadwhere5-10" value="_self">
<param name="desc6-0" value="Tools">
<param name="desturl6-0" value="http://www.scenix.com/tools/index.html">
<param name="loadwhere6-0" value="_self">
<param name="desc6-1" value="Consultants">
<param name="desturl6-1" value="http://www.scenix.com/partners/consultants/index.html">
<param name="loadwhere6-1" value="_self">
<param name="desc6-2" value="Links">
<param name="desturl6-2" value="http://www.scenix.com/partners/links/index.html">
<param name="loadwhere6-2" value="_self">
<param name="desc7-0" value="Sales Reps">
<param name="desturl7-0" value="http://www.scenix.com/sales/reps/index.html">
<param name="loadwhere7-0" value="_self">
<param name="desc7-1" value="Distributors">
<param name="desturl7-1" value="http://www.scenix.com/sales/reps/index.html">
<param name="loadwhere7-1" value="_self">
<param name="desc7-2" value="Tools">
<param name="desturl7-2" value="http://www.scenix.com/tools/index.html">
<param name="loadwhere7-2" value="_self">
<param name="desc7-3" value="Contact">
<param name="desturl7-3" value="http://www.scenix.com/sales/contact/index.html">
<param name="loadwhere7-3" value="_self">
<param name="desc8-0" value="Listings">
<param name="desturl8-0" value="http://www.scenix.com/jobs/listing/index.html">
<param name="loadwhere8-0" value="_self">
<param name="desc8-1" value="Send Resume">
<param name="desturl8-1" value="http://www.scenix.com/jobs/resume/index.html">
<param name="loadwhere8-1" value="_self">
<param name="desc5-7-5" value="Search">
<param name="desturl5-7-5" value="http://www.scenix.com/support/manuals/search/index.html">
<param name="loadwhere5-7-5" value="_self">
<param name="desc3-3" value="Partners">
<param name="desturl3-3" value="http://www.scenix.com/virtual/application/index.html">
<param name="loadwhere3-3" value="_self">
<param name="desc3-4" value="Search">
<param name="desturl3-4" value="http://www.scenix.com/virtual/search/index.html">
<param name="loadwhere3-4" value="_self">
<param name="desc3-5" value="Links">
<param name="desturl3-5" value="http://www.scenix.com/virtual/links/index.html">
<param name="loadwhere3-5" value="_self">
<param name="desc3-6" value="Feedback">
<param name="desturl3-6" value="http://www.scenix.com/virtual/feedback/index.html">
<param name="loadwhere3-6" value="_self">
<param name="desc1-5" value="Mailing List">
<param name="desturl1-5" value="http://www.scenix.com/products/mailing/index.html">
<param name="loadwhere1-5" value="_self">
<param name="desc5-6-0" value="Search">
<param name="desturl5-6-0" value="http://www.scenix.com/support/manuals/search/index.html">
<param name="loadwhere5-6-0" value="_self">
<param name="subxy3" value="46,-98">
<param name="subxy4" value="38,-57">
<param name="subxy5" value="26,-155">
<param name="subxy6" value="36,-43">
<param name="subxy7" value="37,-57">
<param name="subxy5-6" value="-26,70">
</applet>

</td>

<td align="left" valign="top"><br>

<!-- macro virtual_header stop -->


EOF
;

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




print <<EOF;

<!-- macro main_footer start -->

</td></tr><tr>
<td width="112"></td>
<td><center>
<hr>
<table border="0"><tr><td><a href="/company/index.html"><FONT SIZE="1" FACE="Arial,Helvetica">[Company]</FONT></a></td><td><a href="/products/index.html"><FONT SIZE="1" FACE="Arial,Helvetica">[Products]</FONT></a></td><td><a href="/tools/index.html"><FONT SIZE="1" FACE="Arial,Helvetica">[Tools]</FONT></a></td><td><a href="/virtual/index.html"><FONT SIZE="1" FACE="Arial,Helvetica">[Peripherals]</FONT></a></td><td><a href="/news/index.html"><FONT SIZE="1" FACE="Arial,Helvetica">[News]</FONT></a></td><td><a href="/support/index.html"><FONT SIZE="1" FACE="Arial,Helvetica">[Support]</FONT></a></td><td><a href="/partners/index.html"><FONT SIZE="1" FACE="Arial,Helvetica">[Partners]</FONT></a></td><td><a href="/sales/index.html"><FONT SIZE="1" FACE="Arial,Helvetica">[Sales]</FONT></a></td><td><a href="/jobs/index.html"><FONT SIZE="1" FACE="Arial,Helvetica">[Jobs]</FONT></a></td><td><a href="/search/index.html"><FONT SIZE="1" FACE="Arial,Helvetica">[Search]</FONT></a></td></tr></table>
<hr>
<font face="Arial,Helvetica" size="2">
Scenix Semiconductor, Inc.| 3160 De La Cruz Blvd., Ste. 200 | Santa Clara, CA 95054<br>
Tel: 408.327.8888 | Fax: 408.327.8880 | Technical Support Hotline: 800.556.0225</font> 
<hr>
<font face="Arial,Helvetica" size="1" color="#006699">&copy; <a href="/copyright.html">Copyright 1998</a>, All Rights Reserved  | <a href="mailto:info\@scenix.com">info\@scenix.com</a> | <a href="/feedback/index.html">Feedback</a></font>
</center></td>
</tr>
</table>

<!-- macro main_footer stop -->

</body>
</html>

EOF
;
