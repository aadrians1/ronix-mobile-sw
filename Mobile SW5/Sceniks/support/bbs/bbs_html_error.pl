###########################################################
#                   BBS_HTML_ERROR.PL
#
# This script was written by Gunther Birznieks.
# Date Created: 4-18-96
#
#   You may copy this under the terms of the GNU General Public
#   License or the Artistic License which is distributed with
#   copies of Perl v5.x for UNIX.
#
# Purpose:
#   Print out the HTML for the ERROR Screen
# 
############################################################
 

print <<__ENDOFERROR__;
<HTML><HEAD>
<TITLE>Problem In BBS Occurred</TITLE>
</HEAD>
<BODY>
<h1>Problem In BBS Occurred</h1>
<HR>
<blockquote>
$error
</blockquote>
<HR>
</BODY></HTML>
__ENDOFERROR__

1;

