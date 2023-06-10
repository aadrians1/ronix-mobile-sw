#!/usr/bin/perl
############################################################
#                       BBS_FORUM.CGI
#
# This script was written by Gunther Birznieks
# Date Created: 4-18-96
#
#   You may copy this under the terms of the GNU General Public
#   License or the Artistic License which is distributed with
#   copies of Perl v5.x for UNIX
#
# Purpose: To provide routines for all BBS Forum activities including
# Posting, Replying, Reading Messages, Deleting old messages, Filtering
# Messages, and Filtering HTML based on Authentication Scripts.
#
# Main Procedures:
#   &PrintPostOrReplyPage = Prints Post/Reply Data EntryScreen
#   &CreatePosting = Posts a Message
#   &ReadMessage = Reads a message
#   &PrintForumPage = Lists all the posts in a forum
#
# Inputs:
#   Form Variables: 
#     forum = Forum name
#     setup = Setup file identifier.  Default is "bbs".
#     session = Session code for authentication
#     post_op = is this a post
#     reply_op = is this a reply
#     create_message_op = is this a create message
#     read = message to read
#
#   Form Variables for pruning List of Messages displayed:
#     first_date = First date in range to view messages
#     last_date = Last date in range to view messages
#     first_days_old = earliest number of days old to view msgs
#     last_days_old = latest number of days old to view msgs
#     keywords = keywords to search for
#     exact_match = "on" if the search is exact rather than pattern
#                   match based
#
#     use_last_read = "on" if $display_new_messages is on,
#             and we want to only see new messages since
#             our last read.  This only works with
#             authentication activated.
#
#     last_read = Last message read in the forum.
#
# Outputs:
#   Depending on the previous form variables, the output 
#   will be a list of forum messages, posting screen, or
#   reading messages screen.
#
# SPECIAL NOTE: 
#
#  If you are interested in file attachments, you must
#  set that information in the following variables:
#  $allow_user_attachments, $maximum_attachment_size,
#  $attach_dir, $attach_url.  These variables are set below.
#
############################################################
$lib = "./Library";
# Read in core BBS variables
require "./bbs.setup";
require "$lib/cgi-lib.pl";

#$| = 1; # Used for troubleshooting
print &PrintHeader;

if ($allow_user_attachments eq "on") {
    $cgi_lib'maxdata = $maximum_attachment_size;
    $cgi_lib'writefiles = "$attach_dir";
}

&ReadParse;

# Allow override of bbs.setup variables if a setup 
# form variable has been invoked
#
$setup_file = $in{"setup"};
if ($setup_file ne  "") {
    require "$setup_file.setup";
}

require "$auth_lib/auth-lib.pl";

# the following sets a defualt BBS script if one is not 
# defined.

if ($bbs_script eq "") {
    $bbs_script = "bbs_forum.cgi";
} 
$forum = $in{"forum"};

($forum_name, $forum_dir) = &GetForumInfo($forum);

$session = $in{"session"};
$is_this_a_new_session = "yes" if ($session eq "");

($session, $username, $group, 
 $firstname, $lastname, $email) =
 &GetSessionInfo($session, "$bbs_script", *in);

$reply_op = $in{"reply_op"};
$reply_op = "on" if ($in{"reply_op.x"} ne "");
$post_op = $in{"post_op"};
$post_op = "on" if ($in{"post_op.x"} ne "");

$create_message_op = $in{"create_message_op"};
$read = $in{"read"};

# $first_date and $last_date allow date parameters to be specified for
# looking at messages along with a keyword search of messages and
# exact match keyword searching on/off.
#
$first_date = $in{"first_date"};
$last_date = $in{"last_date"};
$keywords = $in{"keywords"};
$exact_match = $in{"exact_match"};
$first_days_old = $in{"first_days_old"};
$last_days_old = $in{"last_days_old"};

#
# $create_msg_error will print out as part of the print_forum
# listing if a problem occured while posting a message
#

$create_msg_error = "";

# Use_last_read tells us to use the last read value for the
# user if authentication is turned on.
#

$use_last_read = $in{"use_last_read"};

#
# last_read is the actual value of the last read
# message
#
$last_read = $in{"last_read"};

#
# The following is for posting/replying HTML generation
#
if (($reply_op ne "") || ($post_op ne ""))
{
    &PrintPostOrReplyPage;
} 
#
# The following is for creating the posts
#
elsif ($create_message_op ne "")
{
    &CreatePosting;
}
elsif ($read ne "")
{
    &ReadMessage($read);
}
elsif ($forum ne "")
{
    &PrintForumPage;
}

############################################################
#
# subroutine: ReadMessage 
#   Usage:
#     &ReadMessage($message);
#
#   Parameters:
#     $message = message filename to read
#
#   Output:
#     Takes a message and outputs it as HTML
#     Dependant on the bbs_html_read_message.pl file
############################################################

sub ReadMessage
{
    local($message) = @_;
    local($poster_firstname, $poster_lastname, 
          $poster_email,$post_date_time, 
	  $post_subject, $post_options) =
	&GetMessageHeader("$forum_dir/$message");

    open (MESSAGEFILE, "$forum_dir/$message") ||
	&CgiDie("Could Not Open Message File\n");
    for (1 .. 6) { <MESSAGEFILE>; } # Throwaway header
    $post_message = "";
    while (<MESSAGEFILE>)
    {
	$post_message .= $_;
    }
    close (MESSAGEFILE);
    

if ($no_html_images eq "on")
{
    $post_message =~ s/<(IMG\s*SRC.*)>/&LT;$1&GT;/ig;
    $post_subject =~ s/<(IMG\s*SRC.*)>/&LT;$1&GT;/ig;

} # End of parsing out no images

if ($no_html eq "on")
{
    $post_message =~ s/<([^>]+)>/\&LT;$1&GT;/ig;
    $post_subject =~ s/<([^>]+)>/\&LT;$1&GT;/ig;
} # End of No html

$post_message =~ s/\n\r\n/<p>/g;
$post_message =~ s/\n/<br>/g;

opendir(FORUMDIR, "$forum_dir") ||
    &CgiDie("Could not open $forum_dir directory\n");
$message_number = substr($message,0,6);
@files = sort(grep(/.......$message_number\.msg$/,
         readdir(FORUMDIR)));
closedir(FORUMDIR);

$message_url = &ReadMessageFields;


$post_replies = "";
foreach (@files) {
    ($reply_firstname, $reply_lastname, $reply_email, 
     $reply_date_time, $reply_subject, 
     $reply_options) =
     &GetMessageHeader("$forum_dir/$_");
    $post_replies .= 
      qq!<A HREF="$bbs_script?forum=$forum!;
    $post_replies .= 
      qq!&read=$_&$message_url">!;
    $post_replies .= 
	" $reply_subject " . 
        "(Modified: $reply_date_time)</A><BR>\n";
}

$attach_file = substr($message,0,13) . ".attach";
$post_attach_html = "";

if (-e "$forum_dir/$attach_file") {
    open(ATTACHFILE, "$forum_dir/$attach_file") ||
	&CgiDie("Could Not Open $forum_dir/$attach_file\n");
    chop($attach_info = <ATTACHFILE>);

    ($post_attachment, $post_attachment_filename) = 
      split(/\|/, $attach_info);
    $post_attach_html = 
	qq!<BR><B>Attached File:</B> ! . 
        qq!<A HREF="$attach_url/$post_attachment">
	    $post_attachment_filename</A><BR>!;
    close (ATTACHFILE);
}
require "bbs_html_read_message.pl";

} # End of ReadMessage

############################################################
#
# subroutine: PrintForumPage 
#  Usage:
#    &PrintForumPage;
#
#   Parameters:
#     None, but CGI Form Variables below affect
#     the list of information that comes up
#       first_date = Date To Start Reading Messages From
#       last_date  = Date To Last Reading
#       keywords   = Keywords To Search On
#       exact_match= Keyword Search Exact_match
#       first_days_old= Start Reading Messages From 
#                       This Days old
#       last_days_old =Finish Reading Messages From
#                       This Days Old
#
#   Output:
#     Prints the message list in a forum based on
#     last read for the user, date ranges, and keyword
#     search if the program is configured for that.
#
############################################################

sub PrintForumPage
{
    local($x);

    opendir(FORUMDIR, "$forum_dir") ||
	&CgiDie("Could Not Open Forum Directory\n");
    @files = sort(grep(/.*msg$/,readdir(FORUMDIR)));
    closedir(FORUMDIR);
    $high_number = substr($files[@files - 1],0,6);
    $low_number = substr($files[0],0,6);

#
# Here we delete old messages based on the global variables if we 
# are starting a new session.
#
    &PruneOldMessages($forum_dir, *files);
#
# If $last_read = something then we have read the forum before
#
# if this is a new session, we update the $last_read, if it is an
# old session, we open the user file to get the last read to compare
# against
#

    if ($display_only_new_messages eq "on"
	&& $last_read eq ""
	&& $use_last_read eq "on") {
	$last_read = 
          &GetUserLastRead($forum_dir, 
                           $username, $session, $high_number);
    }
    $last_read = 0 if ($last_read eq "");

#
# Pruning the file list narrows down what displays to the
# user.  $last_read is the default parameter, 
#
    &PruneFileList(*files, $last_read, $first_date, 
                   $last_date, $first_days_old, 
                   $last_days_old, $keywords,
                   $exact_match, $forum_dir);

# if @files < 1 then we have no messages
# otherwise we need to process them as a tree.

$message_html = "";
@threads = ();
while (@files > 0)
	{
	unshift(@threads,&MakeThreadList(*files));
	}

    $ul_count = 0;
    $prev_level = -1;
foreach $x (@threads) {
    ($level,$messagefile, $thread_date) = 
       split(/\|/,$x);
    if ($level > $prev_level &&
	$level > $display_thread_depth) {
	$level = $prev_level;
    }
    if ($level > $prev_level) {
	$ul_count++;
	$message_html .= "<UL>\n";
    } elsif ($level < $prev_level) {
	for (1 .. ($prev_level - $level)) {
	    $ul_count--;
	    $message_html .= "</UL>\n";
       }
    }
    if ($level == $prev_level) {
	if ($use_list_element ne "on" 
	    || $level == 1) {
	    $message_html .= "<br>";
	}
	$message_html .= "\n";
    }
    if ($level > 1 && $use_list_element eq "on") {
	$message_html .= "<LI>";
    }

($poster_firstname, $poster_lastname, $poster_email, 
 $post_date, $post_subject, $post_options) =
    &GetMessageHeader("$forum_dir/$messagefile");

$message_url = &ReadMessageFields;

$message_html .= 
  qq!<A HREF="$bbs_script?forum=$forum!;
$message_html .= 
  qq!&read=$messagefile&$message_url">\n!;
$message_html .= 
  " $post_subject ($post_date)";

if ($level == 1 && $thread_date ne $post_date)
{
    $message_html .= 
      "";
}   
$message_html .= "</A>";

    $prev_level = $level;
} # End of foreach thread

$message_html .= "\n";
for (1..$ul_count) {
    $message_html .= "</UL>\n";
}

require "bbs_html_forum.pl";

} # end of PrintForumPage

############################################################
#
# subroutine: PrintPostOrReplyPage 
#  Usage:
#    &PrintPostOrReplyPage;
#
#   Parameters:
#     None, but CGI Form Variables below affect
#     the form that comes up if the action that
#     is being taken is a reply to a message instead
#     of a fresh post.
#       reply_to_message = Message # We are replying to
#       email_reply = email to notify that a reply has
#                     occured
#       post_subject = Subject of message we are
#                      replying to.
#
#   Output:
#     HTML Output for the Create Post (or Reply) Page
#
############################################################

sub PrintPostOrReplyPage
{
    local($options, $previous_message);
    local($reply_to_message, $email_reply);
    local($title, $header);
    local($email_tag, $reply_to_email);
    $previous_message = "";
    $reply_to_message = "";
    $email_reply = "";

    $title = "Post Your Message";
    $header = "Posting Message to $forum_name";

    if ($reply_op ne "")
    {
       $reply_to_message = $in{"reply_to_message"};
       $email_reply = $in{"email_reply"};
       $title = "Reply to a Message";
       $header = 
	   "Replying to a Message<br>$forum_name Newsgroup";
       $post_message = "";
       open (REPLYFILE, 
	     "$forum_dir/$reply_to_message") ||
		 &CgiDie("Could not open reply message");
       chop($post_first_name = <REPLYFILE>);
       chop($post_last_name = <REPLYFILE>);
       <REPLYFILE>;
       chop($post_date = <REPLYFILE>);
       <REPLYFILE>;
       chop($options = <REPLYFILE>);
       if ($options =~ /^options:/) {
	   $options = substr($options,8);
	   ($email_tag,$reply_to_email) = 
	       split(/:/,$options);
       }
       while (<REPLYFILE>) {
	   $post_message .= $_;
       }

       $post_message =~ s/^/>>/g;
       $post_message =~ s/\r/\r>>/g;
       $post_message =~ s/\n/\n>>/g;
       $post_message = 
	   "$post_first_name $post_last_name" . 
	       " on $post_date said:\n\n" 
	       . $post_message;
       close (REPLYFILE);
       $post_subject = $in{"post_subject"};
       $post_subject = "Re: $post_subject" 
	   if !($post_subject =~ /^Re:/i);
   }

    $post_date_time = &GetDateAndTime;
    $post_first_name_field = qq!<INPUT TYPE=text 
	NAME=form_firstname VALUE="$firstname" 
	SIZE=40 MAXLENGTH=50>!;
    $post_last_name_field = qq!<INPUT TYPE=text 
	NAME=form_lastname VALUE="$lastname" 
        SIZE=40 MAXLENGTH=50>!;
    $post_email_field = qq!<INPUT TYPE=text 
	NAME=form_email VALUE="$email" 
        SIZE=40 MAXLENGTH=50>!;

    if ($force_first_name eq "on" 
	&& $firstname ne "") {
	$post_first_name_field = 
	qq!<INPUT TYPE=hidden 
	NAME=form_firstname VALUE="$firstname">!;
	$post_first_name_field .= "$firstname";
    }

    if ($force_last_name eq "on" 
	&& $lastname ne "") {
	$post_last_name_field = 
	qq!<INPUT TYPE=hidden
	NAME=form_lastname VALUE="$lastname">!;
	$post_last_name_field .= "$lastname";
    }

    if ($force_email eq "on" 
	&& $email ne "") {
	$post_email_field = 
        qq!<INPUT TYPE=hidden
	NAME=form_email VALUE="$email">!;
	$post_email_field .= "$email";
    }

#    $post_want_email = "";
#    if ($allow_reply_email eq "on") {
#	$post_want_email = 
#    "<BR><INPUT TYPE=CHECKBOX" . 
#	    " NAME=post_want_email>" . 
#            "Check Here If You Want Replies " .
#	    "Emailed To You Automatically<BR>";
#    }

    $post_attachment = "";
    if ($allow_user_attachments eq "on") {
	$post_attachment = 
	    "<P>Attach A File Here:
<INPUT TYPE=FILE NAME=post_attachment><BR>";
    }
    require "bbs_html_create_message.pl";

} # End of PostOrReply

############################################################
#
# subroutine: CreatePosting
#  Usage:
#    &CreatePosting;
#
#   Parameters:
#     None, but CGI Form Variables below affect
#     how the message is posted.
#       form_firstname = firstname of poster
#       form_lastname = lastname of poster
#       form_email = email of poster
#       form_subject = subject of the post
#       form_message = body of the post
#       reply_to_message = message we are replying to
#       reply_to_email = email address of user we are
#                        replying to
#       post_want_email = "on" if we want email replies
#       post_attachment = file upload attachment
#
#   Output:
#     Posts the message to a file and then prints the 
#     list of forum messages.
#
############################################################

sub CreatePosting
{
    local ($create_error);
    $form_firstname = $in{"form_firstname"};
    $form_lastname = $in{"form_lastname"};
  
    $form_email = $in{"form_email"};

    $form_subject = $in{"form_subject"};

    $form_firstname =~ s/\n//g;
    $form_lastname =~ s/\n//g;
    $form_email =~ s/\n//g;
    $form_subject =~ s/\n//g;

    $form_message = $in{"form_message"};

    $reply_to_message = $in{"reply_to_message"};
    if ($reply_to_message < 1) 
    {
       $reply_to_message = "000000";
   } else {
       $reply_to_message = 
	   substr($reply_to_message,0,6);
   }

    $reply_to_email = $in{"reply_to_email"};
    $post_date_time = &GetDateAndTime;

    $form_options = "";
    $post_want_email = $in{"post_want_email"};
    if ($post_want_email eq "on" 
	|| $force_reply_email eq "on") {
	$form_options = "email:$form_email";
    }

    $create_error = 0;
if ($require_subject eq "on" &&
    $form_subject eq "") {
    $create_error = 1;
    $create_msg_error .= 
      "<h3>You Did Not Enter A Subject!</h3></H2>";
}
if ($require_first_name eq "on" &&
    $form_firstname eq "") {
    $create_error = 1;
    $create_msg_error .= 
      "<h3>You Did Not Enter Your First name!</h3>";
}
if ($require_last_name eq "on" && 
    $form_lastname eq "") {
    $create_error = 1;
    $create_msg_error .= 
      "<h3>You Did Not Enter Your Last Name!</h3>";
}
if ($require_email eq "on" &&
    $form_email eq "") {
    $create_error = 1;
    $create_msg_error .= 
      "<h3>You Did Not Enter Your Email Address!</h3>";
}

if ($create_error == 1) {
$create_msg_error = "<HR><H2>Error Posting To BBS!</H2> " .
  $create_msg_error;
}

if ($create_error != 1) {
    $whole_msg = "";
    $whole_msg .= "$form_firstname\n";
    $whole_msg .= "$form_lastname\n";
    $whole_msg .= "$form_email\n";
    $whole_msg .= "$post_date_time\n";
    $whole_msg .= "$form_subject\n";
    $whole_msg .= "options:$form_options\n";
    $whole_msg .= "$form_message\n";

opendir(FORUMDIR, "$forum_dir") ||
    &CgiDie("Couldn't Open $forum_dir");
@files = sort(grep(/.*msg$/,readdir(FORUMDIR)));
closedir(FORUMDIR);
$high_number = substr($files[@files - 1],0,6);
@files = ();
$high_number++;

$high_number = sprintf("%6d",$high_number);
$high_number =~ tr/ /0/;
    $high_number = "000001" 
	if ($high_number eq "000000");
$message_name = "$high_number-$reply_to_message";

open(WRITEMSG, ">$forum_dir/$message_name.msg") ||
    &CgiDie("Could't open $message_name.msg for writing");
print WRITEMSG $whole_msg;
close (WRITEMSG);

$post_attachment = $in{"post_attachment"};
$post_attachment_filename = 
    $incfn{"post_attachment"};
#
# Parse out the %Hex symbols and make it into alphanumeric
#
$post_attachment_filename =~ 
    s/%([A-Fa-f0-9]{2})/pack("c",hex($1))/ge;

    if ($post_attachment_filename ne "") {
	rename($post_attachment, 
	       "$attach_dir/$forum-$message_name.bin");
	open(WRITEATTACH, 
	     ">$forum_dir/$message_name.attach") ||
		 &CgiDie("Could Not Open Attachment\n");
	print WRITEATTACH 
	    "$forum-$message_name.bin" . 
		"|$post_attachment_filename\n";
	close(WRITEATTACH);
    } else {
	unlink("$post_attachment");
    }

#
# The following handles the email system
#

    $reply_to_email = $in{"reply_to_email"};
    if ($reply_to_email ne "" && 
	$send_reply_email eq "on") {
	require "$lib/mail-lib.pl";
	$reply_subject = 
	    "Reply to your $forum_name message.";
	&send_mail($from_email, $reply_to_email, 
		   $reply_subject, 
		   "The Message:\n\n" . $form_message);

    } # End of reply_to_email

    $reply_to_email = $in{"reply_to_email"};
    $form_email = $in{"form_email"};
    $mailadr = "stephan.thaler\@scenix.com";

    {
    require "$lib/mail-lib.pl";
    $reply_subject = 
    "Message from $forum_name newsgroup";
	&send_mail($form_email, $mailadr, 
		   $reply_subject, 
		   "The Message:\n\n" . $form_message);
  }
} # end of if $create_error == 1

&PrintForumPage;

} # End of CreatePosting

############################################################
#
# subroutine: PruneFileList
#  Usage:
#    &PruneFileList(*files, $last_read, $first_date,
#    $last_date, $first_days_old, $last_days_old,
#    $keywords, $exact_match, $forum_dir);
#
#   Parameters:
#     The non-filename related parameters are criteria
#     used to prune the file list down so that not all
#     the messages show up in the forum message list.
#
#     *files = reference to a list of message filenames
#              in the forum for pruning.
#     $last_read = last read message number for the user
#                  so that only new messages are read
#     $first_days_old= Start Reading Messages From 
#                      This Days old
#     $last_days_old =Finish Reading Messages From
#                     This Days Old
#     $first_date = Date To Start Reading Messages From
#     $last_date  = Date To Last Reading
#     $keywords   = Keywords To Search On
#     $exact_match= Keyword Search Exact_match
#
#   Output:
#     Prunes a list of messages that do not satisfy the
#     criteria being passed to the routine (Such as a
#     date range) from the *files reference to an array
#     of message filenames.
#
############################################################

sub PruneFileList
{
    local(*files, $last_read, $first_date, $last_date,
	  $first_days_old, $last_days_old, $keywords,
	  $exact_match, $forum_dir) = @_;
    local($x, $filename);
    local($month, $day, $year, $comp_date);
    local($file_date);

    @keyword_list = split(/\s+/,$keywords);
    for ($x = @files; $x > 0; $x--)
    {
#
# CASE 1: Prune becauase we've read this already
#
       if ($last_read > 0 
	   && substr($files[$x-1],0,6) <= $last_read
	   && $display_only_new_messages eq "on")
       {
	   &RemoveElement(*files,$x-1);
	   next;
       }
 
       $filename = "$forum_dir/$files[$x - 1]";
#
# CASE 2: Prune because it does not fit range of days old
#

       if (($first_days_old ne "") 
	   && ((-M $filename) > $first_days_old)) {
	   &RemoveElement(*files,$x-1);
	   next;
       }

       if (($last_days_old ne "") 
	   && ((-M $filename) < $last_days_old)) {
	   &RemoveElement(*files, $x-1);
	   next;
       }
#
# CASE 3: Prune because it does not fit date range
#
       # If we are comparing the files by date, we need to get
       # date statistics
       if ($first_date ne "" 
	   || $last_date ne "") {
	   ($month, $day, $year) = 
	       split(/\//, $first_date);
# We need to pad the month and day to be two digits for 
# date comparison
	   $month = "0" . $month 
	       if (length($month) < 2);
	   $day = "0" . $day 
	       if (length($day) < 2);
# if the year was entered as two digits, we should convert it
# to a 4 digit year.  Years from 51-99 are taken to be 1951 and
# 1999.  Years from 00-50 are 2000 to 2050.
	   if ($year > 50 && $year < 1900) {
	       $year += 1900;
	   }
	   if ($year < 1900) {
	       $year += 2000;
	   }
# We order the date in order of year, month, and day.  This allows
# us to use a normal numeric comparison between days to see which is
# greater than another one.  
# 
# Since days make up months and months make up years, putting them
# in this order works for normal >,< comparisons.
#
# eg 19960115 is numerically greater than 19951230.
#
	   $comp_first_date = $year . $month . $day;

	   ($month, $day, $year) = 
	       split(/\//, $last_date);
	   $month = "0" . $month 
	       if (length($month) < 2);
	   $day = "0" . $day if (length($day) < 2);
	   if ($year > 50 && $year < 1900) {
	       $year += 1900;
	   }
	   if ($year < 1900) {
	       $year += 2000;
	   }
	   $comp_last_date = $year . $month . $day;

	   #$filedate = (-M $filename);
	   $file_date = (stat($filename))[9];
	   ($day, $month, $year) = 
	       (localtime($file_date))[3,4,5];
	   $month++;
	   $month = "0" . $month 
	       if (length($month) < 2);
	   $day = "0" . $day if (length($day) < 2);
	   if ($year > 50 && $year < 1900) {
	       $year += 1900;
	   }
	   if ($year < 1900) {
	       $year += 2000;
	   }
	   $file_date = $year . $month . $day;

	   if ($first_date ne "") {
	       if ($file_date < $comp_first_date) {
		   &RemoveElement(*files, $x-1);
		   next;
	       }
	   } # End of first date

	   if ($last_date ne "") {
	       if ($file_date > $comp_last_date) {
		   &RemoveElement(*files, $x-1);
		   next;
	       }
	   } # End of last date

       } # End of First or Last Date 
#
# CASE 4: Prune because keywords not found in file
#
       if ($keywords ne "") {
	@not_found_words = @keyword_list;
	open(SEARCHFILE, $filename);
	while(<SEARCHFILE>) {
	    $line = $_;
	    &FindKeywords($exact_match, $line,
			  *not_found_words);
	} # End of SEARCHFILE
	close (SEARCHFILE);
	# If any keywords were not found prune the file
	if (@not_found_words > 0) {
	    &RemoveElement(*files, $x - 1);
	    next;
	}

       } # End of keywords
    } # End of for loop

} # End of PruneFileList

############################################################
#
# subroutine: FindKeywords
#  Usage:
#    &FindKeywords($exact_match, $line, 
#                  *not_found_words);
#
#   Parameters:
#     $exact_match = 'on' if keyword search is exact match
#     $line = line to search
#     *not_found_words = array of words we have not 
#     found yet.
#
#   Output:
#     *not_found_words array gets elements deleted as the
#     keywords get found in the $line.
#
############################################################

sub FindKeywords
{
    local($exact_match, $line, *not_found_words) = @_;
    local($x, $match_word);

    if ($exact_match eq "on") {
	for ($x = @not_found_words; $x > 0; $x--) {
# \b matches on word boundary	    
	    $match_word = $not_found_words[$x - 1];
	    if ($line =~ /\b$match_word\b/i) {
		splice(@not_found_words,$x - 1, 1);
	    } # End of If
	} # End of For Loop
    } else {
	for ($x = @not_found_words; $x > 0; $x--) {
	    $match_word = $not_found_words[$x - 1];
	    if ($line =~ /$match_word/i) {
		splice(@not_found_words,$x - 1, 1);
	    } # End of If
	} # End of For Loop
    } # End of ELSE

} # End of FindKeywords

############################################################
#
# subroutine: GetUserLastRead
#  Usage:
#    &GetUserLastRead($forum_dir, $username, $high_number);
#
#   Parameters:
#     $forum_dir = directory path for the forum
#     $username = username dirived from authentications
#     $session = session id
#     $high_number = the highest message number
#
#   Output:
#     Returns $last_read = last read message number.
#     $last_read is written over with the highest message
#     number IF the session id is different from the session
#     from the last_read 
#
############################################################

sub GetUserLastRead
{
    local($forum_dir, $username, 
	  $session, $high_number) = @_;
    local($last_read, $old_session);

unless (-e "$forum_dir/$username.dat")
	{
	$last_read = 0;
	}
	else
	{
	open (USERFILE, "$forum_dir/$username.dat") ||
	    &CgiDie("Error Opening Userfile $username\n");
	$last_read = <USERFILE>;
	$old_session = <USERFILE>;
	chop ($last_read);
	chop($old_session);
	close (USERFILE);
	}

    if ($session ne $old_session) {
	open (USERFILE, ">$forum_dir/$username.dat") ||
	    &CgiDie("Error Opening Userfile $username\n");
	print USERFILE "$high_number\n";
	print USERFILE "$session\n";
	close (USERFILE);
    }

$last_read;

} #End of GetUserLastRead

############################################################
#
# subroutine: GetDateAndTime
#  Usage:
#    &GetDateAndTime(;
#
#   Parameters:
#     None.
#
#   Output:
#     Returns a string of the current date and time.
#
############################################################

sub GetDateAndTime
{
    local ($sec, $min, $hour, $mday, $mon);
    local($year, $wday, $yday, $isdst);
    local ($ampm, $currentdatetime);

($sec, $min, $hour, $mday, $mon, 
 $year, $wday, $yday, $isdst) =
    localtime(time);
$mon++;
$ampm = "AM";
$ampm = "PM" if ($hour > 11);
$hour = $hour - 12 if ($hour > 12);
if (length($min) == 1)
{
    $min = "0" . $min;
}

"$mon/$mday/$year $hour:$min $ampm";

} # End of GetDateAndTime

############################################################
#
# subroutine: GetMessageHeader
#  Usage:
#    &GetMessageHeader($filename);
#
#   Parameters:
#     $filename = message filename to read header from
#
#   Output:
#      Returns an array of the items in the message header.
#      
#      $poster_firstname = first name
#      $poster_lastnamne = last name
#      $poster_email = email address of poster
#      $post_date = date/time of the posting
#      $post_subject = subject of the post
#      $post_options = post options
#
############################################################

sub GetMessageHeader
{
    local($filename) = @_;
    local($poster_firstname, $poster_lastname, 
	  $poster_email, $post_date, 
	  $post_subject, $post_options);

    open (MESSAGEFILE, "$filename") ||
	&CgiDie("Could Not Open $filename hdr\n");
    chop($poster_firstname = <MESSAGEFILE>);
    chop($poster_lastname = <MESSAGEFILE>);
    chop($poster_email = <MESSAGEFILE>);
    chop($post_date = <MESSAGEFILE>);
    chop($post_subject = <MESSAGEFILE>);
    chop($post_options = <MESSAGEFILE>);

    if ($post_options =~ /^options:/) {
	$post_options = substr($post_options,8);
    }
    close(MESSAGEFILE);

($poster_firstname, $poster_lastname, $poster_email, 
 $post_date, $post_subject, $post_options);

} # End of GetMessageHeader

############################################################
#
# subroutine: MakeThreadList
#  Usage:
#     &MakeThreadList(*file_list);
#
#   Parameters:
#     *file_list = array of message file names to make
#                  a threaded, hierarchical message
#                  listing out of. 
#
#   Output:
#     @threads = an array containing the threaded,
#                hierarchical message structure.
#    
#
############################################################

sub MakeThreadList
{
local(*file_list) = @_;
local(@threads,$seq_ptr);
local($sequence,$previous);
$seq_ptr = @file_list - 1;
if ($seq_ptr > -1)
{
($poster_firstname, $poster_lastname, $poster_email, 
 $post_date, $post_subject, $post_options) =
    &GetMessageHeader("$forum_dir/@file_list[$seq_ptr]");
while(1)
	{
	    @file_list[$seq_ptr] .= "|$post_date";
	    $sequence = @file_list[$seq_ptr];
	    $previous = substr($sequence,7,6);
	    $previous_pointer = 
		&GetPointer(*file_list, $previous);
	if  (($previous eq "000000") || 
		($previous_pointer == -1))
		{
		last;
		}
	$seq_ptr = $previous_pointer;
	} #End of while loop

# $sequencepoint is now the top of the thread for the highest sequence #
@seq_stack = ($seq_ptr);
$cur_stack_size = 1;
push(@threads, "$cur_stack_size|$sequence");


while(@file_list > 0)
{
$next_seq = substr($sequence,0,6);
$next_ptr = 
    &GetNextThread(*file_list, $next_seq, $seq_ptr);

if ($next_ptr > -1)
	{
	$cur_stack_size++;
	push(@seq_stack, $next_ptr);
	$sequence = $file_list[$next_ptr];
	$seq_ptr = $next_ptr;
	push(@threads, "$cur_stack_size|$sequence");
	}
else
	{
	@file_list = 
	    &RemoveElement(*file_list, $seq_ptr);
	$cur_stack_size--;
	pop(@seq_stack);
	if (@seq_stack > 0) 
		{		
		$seq_ptr = 
		    $seq_stack[@seq_stack - 1];
		$sequence = $file_list[$seq_ptr];
		}
	else
		{
		last;		
		}
	}
} # End of While Loop

@threads;

} # End of if seq_ptr > 0
else {

# if there are no sequence numbers, return nothing for a thread
();
} # End of IF Seq_ptr > 0

} # end of MakeThreadList

############################################################
#
# subroutine: GetPointer
#  Usage:
#    &GetPointer(*file_list, $seq);
#
#   Parameters:
#     *file_list = list of files
#     $seq = sequence number
#
#   Output:
#     Returns a numerical pointer into the array of 
#     files where the sequence number appears as the
#     message number.  Remember, messages appear as 
#     [MESSAGE NUMBER]-[REPLY TO NUMBER].MSG format.
#     where the message number and reply to number
#     are a fixed 6 digits.
#
############################################################

sub GetPointer
{
local(*file_list, $seq) = @_;
local($pointer,$x);
$pointer = -1;
for ($x = 0;$x < @file_list; $x++)
	{
	if (substr($file_list[$x],0,6) eq $seq)
		{
		$pointer = $x;
		last;
		}
	}

$pointer;

} # End of GetPointer

############################################################
#
# subroutine: GetNextThread
#  Usage:
#    &GetNextThread(*file_list, $seq, $start);
#
#   Parameters:
#     *file_list = list of message filenames
#     $seq = sequence/message # to search for
#     $start = pointer into array to start searching from
#
#   Output:
#     Returns the pointer into the array of message
#     filenames where the next reply to the message # is.
#
############################################################

sub GetNextThread
{
local(*file_list, $seq, $start) = @_;
local($pointer, $x);
$pointer = -1;

for ($x = $start; $x < @file_list; $x++)
	{
	if (substr($file_list[$x],7,6) eq $seq)
		{
		$pointer = $x;
		last;
		}
	}

$pointer;

} # End of GetNextThread

############################################################
#
# subroutine: RemoveElement
#  Usage:
#    &RemoveElement;
#
#   Parameters:
#     *file_list = array of message numbers
#     $number = pointer into the array of the
#               element to remove
#
#   Output:
#     *file_list without the $number element.
#
############################################################

sub RemoveElement
{
local(*file_list, $number) = @_;

if ($number > @file_list)
	{
	die "Number was higher than " .
	    "number of elements in file list";
	}
splice(@file_list,$number,1);

@file_list;

} # End of RemoveElement

############################################################
#
# subroutine: GetForumInfo
#  Usage:
#    &GetForumInfo($forum);
#
#   Parameters:
#     $forum = abbreviated forum identifier
#
#   Output:
#     Returns an array of the forum name and forum
#     directory.
#
############################################################

sub GetForumInfo
{
    local($forum) = @_;
    local($forum_name, $forum_dir, $x);
    local($forum_number);

$forum_number = -1;

for ($x = 1; $x <= @forum_variable; $x++)
	{
	if ($forum_variable[$x - 1] eq $forum)
		{
		$forum_number = $x - 1;
		last;
		}
	} # End of FOR forum_variables

if ($forum_number > -1)
{
    $forum_name = @forums[$forum_number];
    $forum_dir = @forum_directories[$forum_number];
} else
{
    $forum_name="";
    $forum_dir = "";
    if ($forum eq "") {
        $forum = "Forum Not Entered";
    }
    $error = 
	"<strong>Forum '$forum' Not Found</strong>";
    require "bbs_html_error.pl";
    die;
}
($forum_name, $forum_dir);

} # end of GetForumInfo

############################################################
#
# subroutine: PruneOldMessages
#  Usage:
#    &PruneOldMessages($forum_dir, *files);
#
#   Parameters:
#     $forum_dir = directory of forum
#     *files = filename list in forum
#
#   Output:
#     Unlinks (deletes) messages and attachments in the
#     forum directory based on age or sequence number 
#     of the post.
#
############################################################

sub PruneOldMessages {
    local($forum_dir, *files) = @_;
    local($x);
    local($prunefile, $attachfile, $attachfile2);
#
# We prune on the basis of 
# 
# AGE IN DAYS:
# $prune_how_many_days
#
# AGE BY SEQUENCE NUMBER
# $prune_how_many_sequences
#

    for ($x = @files; $x >= 1; $x--) {
	$prunefile = "$forum_dir/$files[$x - 1]";
# $attachfile is the descriptive attachment file in the
# forum directory.  $attachfile2 = is the real uploaded 
# attachment 

        $attachfile = "$forum_dir/" .
            substr($files[$x - 1],0,14) . 
            "attach";
        $attachfile2 = "$attach_dir/" .
            "$forum-" .
            substr($files[$x - 1],0,14) .
            "bin";
	# First we check the age in days
	if ((-M "$prunefile" > $prune_how_many_days) &&
	    ($prune_how_many_days > 0)) {
	    unlink("$prunefile");
	    unlink($attachfile);
            unlink($attachfile2);
	    &RemoveElement(*files, $x - 1);
	    next;
	}
    

	#
	# Check the sequence and delete if it is too old
	#

	if (($x <= (@files - $prune_how_many_sequences))
	    && ($prune_how_many_sequences != 0)) {
	    unlink("$prunefile");
	    unlink($attachfile);
            unlink($attachfile2);
	    &RemoveElement(*files, $x - 1);
	    next;
	} 
    } # End of for all files

} # End of PruneOldMessages

############################################################
#
# subroutine: HiddenFields 
#  Usage:
#    &HiddenFields;
#
#   Parameters:
#     None.
#
#   Output:
#     Returns a buffer containing the HTML code for
#     hidden fields that should be passed from screen to
#     screen in the BBS Forum.
#
############################################################

sub HiddenFields {
    local ($buf);
    local ($h);

    $h = "<INPUT TYPE=HIDDEN NAME";

    $buf = qq!$h=session VALUE="$session">\n!;
    if ($first_date ne "") {
	$buf .= 
	    qq!$h=first_date VALUE="$first_date">\n!;
    }
    if ($last_date ne "") {
	$buf .= 
	    qq!$h=last_date VALUE="$last_date">\n!;
    }
    if ($first_days_old ne "") {
	$buf .= 
	    qq!$h=first_days_old 
		VALUE="$first_days_old">\n!;
    }
    if ($last_days_old ne "") {
	$buf .= 
	    qq!$h=last_days_old 
		VALUE="$last_days_old">\n!;
    }
    if ($keywords ne "") {
	$buf .= 
	    qq!$h=keywords VALUE="$keywords">\n!;
    }
    if ($exact_match ne "") {
	$buf .= 
	    qq!$h=exact_match VALUE="$exact_match">\n!;
    }
    if ($use_last_read = "on") {
	$buf .= 
	    qq!$h=use_last_read VALUE="$use_last_read">\n!;
    }
   if ($last_read ne "") {
	$buf .= 
	    qq!$h=last_read VALUE="$last_read">\n!;
    }

    if ($setup_file ne "") {
	$buf .= 
	    qq!$h=setup VALUE="$setup_file">\n!;
    }

    $buf;
} # End of Hidden Fields


############################################################
#
# subroutine: ReadMessageFields 
#  Usage:
#    &ReadMessageFields;
#
#   Parameters:
#     None.
#
#   Output:
#     Returns a buffer containing the URL code for
#     fields that should be passed from screen to screen
#     in the BBS program
#
############################################################

sub ReadMessageFields {
    local ($buf);
    local ($h);


    $buf = qq!session=$session&!;
    if ($first_date ne "") {
	$buf .= 
	    qq!first_date="$first_date"&!;
    }
    if ($last_date ne "") {
	$buf .= 
	    qq!last_date=$last_date&!;
    }
    if ($first_days_old ne "") {
	$buf .= 
	    qq!first_days_old=$first_days_old&!;
    }
    if ($last_days_old ne "") {
	$buf .= 
	    qq!$last_days_old=$last_days_old&!;
    }
    if ($keywords ne "") {
	$buf .= 
	    qq!keywords=$keywords&!;
    }
    if ($exact_match ne "") {
	$buf .= 
	    qq!exact_match=$exact_match&!;
    }
    if ($use_last_read = "on") {
	$buf .= 
	    qq!use_last_read=$use_last_read&!;
    }
    if ($last_read ne "") {
	$buf .= 
	    qq!last_read=$last_read&!;
    }
    if ($setup_file ne "") {
	$buf .= 
	    qq!setup=$setup_file&!;
    }
    # We need to filter out some illegal characters
    # from the URL.
    $buf =~ s/ /%20/;
    $buf =~ s/\//%2F/;
    chop($buf); # Get rid of last &
    $buf;
} # End of ReadMessageFields



