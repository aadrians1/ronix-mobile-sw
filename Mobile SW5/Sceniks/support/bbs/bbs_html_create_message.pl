###########################################################
#                   BBS_HTML_CREATE_MESSAGE.PL
#
# This script was written by Gunther Birznieks.
# Date Created: 4-18-96
#
#   You may copy this under the terms of the GNU General Public
#   License or the Artistic License which is distributed with
#   copies of Perl v5.x for UNIX.
#
# Purpose:
#   Print out the HTML for the CREATE MESSAGE Screen
# 
############################################################
 
# Hidden fields need to get passed from screen to screen

$print_hidden_fields = &HiddenFields;

$form_hdr = qq!<FORM METHOD=POST ACTION="$bbs_script" !;
$form_hdr .= qq!ENCTYPE="multipart/form-data">!;

if ($post_attachment eq "") {
$form_hdr = qq!<FORM METHOD=POST ACTION="$bbs_script">!;
}
print <<__ENDHTML__;
<HTML>
<HEAD>
<TITLE>$title</TITLE>
</HEAD>
<BODY BGCOLOR = "FFFFFF" TEXT = "000000">
<H2>$header</H2>
<HR>
$form_hdr
<INPUT TYPE=HIDDEN NAME=reply_to_message VALUE="$reply_to_message">
<INPUT TYPE=HIDDEN NAME=forum VALUE="$forum">
$print_hidden_fields
<INPUT TYPE=HIDDEN NAME=reply_to_email VALUE="$reply_to_email">
<TABLE>
<TR>
<TH align=right>First Name:</TH>
<TD>$post_first_name_field</TD>
</TR><TR>
<TH align=right>Last Name:</TH>
<TD>$post_last_name_field</TD>
</TR>
<TR>
<TH align=right>Email:</TH>
<TD>$post_email_field</TD>
</TR>
<TR>
<TH align=right>Date:</TH>
<TD>$post_date_time</TD>
</TR>
<TR>
<TH align=right>Subject:</TH>
<TD><INPUT TYPE=text NAME=form_subject VALUE="$post_subject"
SIZE=40 MAXLENGTH=50></TD>
</TR>
</TABLE>
<STRONG>Enter Message Below:</STRONG><BR>
<TEXTAREA NAME=form_message ROWS=10 COLS=60 
WRAP=physical>
$post_message
</TEXTAREA>
$post_attachment
$post_want_email
<CENTER>
<HR>
<INPUT TYPE=SUBMIT NAME=create_message_op VALUE="Submit Message">
<INPUT TYPE=RESET VALUE="Clear Values">
<HR>
<P>
<INPUT TYPE=IMAGE NAME=toplevel_op SRC="$bbs_buttons/message_archive_top.gif"
BORDER="0"> 

<P></CENTER>


</FORM>
</BODY>
</HTML>

__ENDHTML__


1;
