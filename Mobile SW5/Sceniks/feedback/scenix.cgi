#!/usr/local/bin/perl

# This Perl5 script processes the feedback form for Scenix Semiconductor.
# Created 8/13/97 by Jeff Martin

if ($ENV{'REQUEST_METHOD'} eq 'POST')
 {
  # read in the entire set of responses
  read(STDIN,$buffer,$ENV{'CONTENT_LENGTH'});

  # split the field,value pairs and store into the list @pairs
  @pairs = split (/&/,$buffer);

  # for each pair, convert special symbols and store into %FORM using the
  # $name as the key to each value.
  foreach $pair (@pairs)
   {
    ($name,$value) = split (/=/,$pair);
    $value =~ tr/+/ /;
    $name =~ tr/+/ /;
    $value =~ s/%([a-fA-F0-9]{2})/pack('C',hex($1))/eg;
    $name =~ s/%([a-fA-F0-9]{2})/pack('C',hex($1))/eg;
    if ($FORM{$name})
     {
      $FORM{$name} .= ", $value";
     }
    else
     {
      $FORM{$name} = $value;
     }
   }

  # The key "S" will signify the subject of the email result
  $FORM{'S'} = "User submission" unless ($FORM{'S'});
 
  # Open a pipe to sendmail using the handle "MESSAGE"
  open (MESSAGE,"| /usr/lib/sendmail -t");

  # Print the To:, Reply-To: and Subject fields
  print MESSAGE "To: $FORM{'T'}\n";
  print MESSAGE "Reply-To: $FORM{'Email Address'}\n";
  print MESSAGE "Subject: $FORM{S} from: $FORM{'Email Address'}\n\n";

  # print out the field names and data
  if ($FORM{'Name'})
    {print MESSAGE "\n          NAME:  $FORM{'Name'}";}
  if ($FORM{'Title'})
    {print MESSAGE "\n         TITLE:  $FORM{'Title'}";}
  if ($FORM{'Company'})
    {print MESSAGE "\n       COMPANY:  $FORM{'Company'}";}
  if ($FORM{'Address'})
    {print MESSAGE "\n       ADDRESS:  $FORM{'Address'}";}
  if ($FORM{'City'})
    {print MESSAGE "\nCITY/STATE/ZIP:  $FORM{'City'},";}
  if ($FORM{'State'})
    {print MESSAGE "  $FORM{'State'}.";}
  if ($FORM{'Zip'})
    {print MESSAGE "  $FORM{'Zip'}";}
  if ($FORM{'Country'})
    {print MESSAGE "\n       COUNTRY:  $FORM{'Country'}";}
  if ($FORM{'Phone'})
    {print MESSAGE "\n         PHONE:  $FORM{'Phone'}";}
  if ($FORM{'Fax'})
    {print MESSAGE "   FAX:  $FORM{'Fax'}";}
  if ($FORM{'Email Address'})
    {print MESSAGE "\n         EMAIL:  $FORM{'Email Address'}";}
  if ($FORM{'Hear'})
    {print MESSAGE "\n\nI heard about the SX from a(n) $FORM{'Hear'}.";}
  if ($FORM{'Hear Name'})
    {print MESSAGE "\nThe show, magazine or other".
                   " source was $FORM{'Hear Name'}.";}
  if ($FORM{'Industry'})
    {print MESSAGE "\n\nThe industry I work in is $FORM{'Industry'}.";}
  if ($FORM{'Micro Usage'})
    {print MESSAGE "\n\nOur annual microcontroller usage is ".
                   "$FORM{'Micro Usage'}.";}
  if ($FORM{'Purchase'})
    {print MESSAGE "\n\nWe plan to purchase in $FORM{'Purchase'}.";}
  if ($FORM{'Comments'})
    {print MESSAGE "\n\nMy comments are:\n$FORM{'Comments'}";}

  # Close the Message handle and thus send the mail message
  close MESSAGE;

  # Tell browser to load the response page
  print "Location: http://www.scenix.com/feedback/feedback_response.htm\n\n";

 }
else
 {
  # This form must be using the GET type, we can't handle this.
  &html_header ('Feedback Form Processing Error');
  print "<HR><P>";
  print "There has been a problem processing your form. This ";
  print "cgi-bin does not take GET type input.";
  &html_trailer;
 } 

sub html_header
 {
  print "Content-type: text/html\n\n";
  print "<HTML><HEAD><TITLE>$_[0]</TITLE><H1>$_[0]</H1></HEAD>";
  print "<BODY>";
 }

sub html_trailer
 {
  print "</BODY>";
  print "</HTML>";
 }

