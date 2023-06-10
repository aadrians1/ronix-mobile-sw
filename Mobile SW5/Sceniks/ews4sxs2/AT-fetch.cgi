#!/bin/sh
perl=/usr/local/www/scenix.com/ews4sxs2/perl
eval "exec $perl -x $0 $*"
#!perl

##
## Copyright (c) 1996 Excite, Inc.
##
## This CGI script does one of four things depending on the
## command parameter.  If command is FETCH it finds and returns 
## the index file specified by the db and ext parameters. If
## the command is INFO then we return the modification dates
## and sizes of the index files specified by the db parameter.  
## If the command is LIST_ALL, it returns a list of the all of
## the collections at this server. If the command is LIST_PUB,
## it returns a list of the collections  at this server that 
## are subscribed to Bullseye notification. If the command is 
## EMAIL, it returns the e-mail address of the administrator 
## for that site.
## 


BEGIN {
  $root = "/usr/local/www/scenix.com/ews4sxs2";
  die "Invalid root directory '$root'\n" unless -d $root;
  unshift(@INC, "$root/perllib");
}

$| = 1;

require 'architext.pl';
require 'architextConf.pl';
 
%form = &Architext'readFormArgs;
%attr = &ArchitextConf'readConfig("$root/Architext.conf", $form{'db'});

if ($form{'command'} eq "FETCH") 
{
  $thepath = $attr{'CollectionIndex'}.'/'.$form{'db'}.'.'.$form{'ext'};
  open(IDXFILE, "< $thepath") || die "Couldn't open index file $thepath";

  print "Content-Transfer-Encoding: binary\n";
  print "Content-Type: application/octet-stream\n\n";

  while(<IDXFILE>) {
    print;
  }
  close(IDXFILE);
} 
elsif ($form{'command'} eq "INFO") 
{

  @ftypes = ('ptr', 'info', 'sum', 'url.map', 'sum.map', 'url.idx', 'sum.idx', 'key', 'dat');

  $head = $attr{'CollectionIndex'}.$form{'db'};

  print "Content-Type: text/plain\n\n";

  foreach $type (@ftypes) {
    $thepath = $head . '.' . $type;
    if (($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size, $atime, $modtime, $ctime, $blksize, $blocks) = stat("$thepath")) {
      print "$type $size $modtime\n";
    }
  }
}

elsif ($form{'command'} eq "LIST_ALL") 
{
  opendir(CONF, "$root/collections");
  @dbconf = grep(/\.conf$/, readdir(CONF));
  closedir CONF;

  print "Content-Type: text/plain\n\n";

  foreach $collection (@dbconf) {
    $collection =~ s/\.conf$//;
    print "$collection\n";
  }
}

elsif ($form{'command'} eq "LIST_PUB") 
{
  opendir(CONF, "$root/collections");
  @pubconf = grep(/\.pub$/, readdir(CONF));
  closedir CONF;

  print "Content-Type: text/plain\n\n";

  foreach $collection (@pubconf) {
    $collection =~ s/\.pub$//;
    print "$collection\n";
  }
}

elsif ($form{'command'} eq "EMAIL") 
{
  $eaddr = $attr{'AdminMail'};
  print "Content-Type: text/plain\n\n";
  print "$eaddr\n";
}


elsif ($form{'command'} eq "SPIDER") 
{
  ## returns BUILD if we need to build the url.idx url.map sum.idx and sum.map files
  ## returns GOOD if they are already built and up to date
  ## returns PROGRESS if they are being built at the moment

  $ans = "BUILD";
  $head = $attr{'CollectionIndex'}.$form{'db'};
  if (-e "$head.progress") {
    ($dm, $dm, $dm, $dm, $dm, $dm, $dm, $dm, $dm, $modtime) = stat("$head.progress");
    if ($modtime > (time - 7200)) {
      $ans = "PROGRESS";
    }
    else {
      unlink "$head.progress";
    }
  }
  if (($ans ne "PROGRESS") && (-e "$head.url.idx")
                           && (-e "$head.url.map")
                           && (-e "$head.sum.idx")
                           && (-e "$head.sum.map")) {
    ($dm, $dm, $dm, $dm, $dm, $dm, $dm, $dm, $dm, $mod) = stat("$head.dat");
    ($dm, $dm, $dm, $dm, $dm, $dm, $dm, $dm, $dm, $t1) = stat("$head.url.idx");
    ($dm, $dm, $dm, $dm, $dm, $dm, $dm, $dm, $dm, $t2) = stat("$head.url.map");
    ($dm, $dm, $dm, $dm, $dm, $dm, $dm, $dm, $dm, $t3) = stat("$head.sum.idx");
    ($dm, $dm, $dm, $dm, $dm, $dm, $dm, $dm, $dm, $t4) = stat("$head.sum.map");
    $ans = "GOOD" if (($t1 > $mod) && ($t2 > $mod) && ($t3 > $mod) && ($t4 > $mod));
  }

  print "Content-Type: text/plain\n\n";
  print "$ans\n";
  print "spider-version-1\n";
}

else
{
  die "Invalid command";
}

## HACK!!! this keeps the connection open long enough for us 
## to read the last bytes.
sleep(1);

exit(0);



