#!/bin/sh
perl=/usr/local/www/scenix.com/ews4sxs2/perl
eval "exec $perl -x $0 $*"
#!perl
## Copyright (c) 1996 Excite, Inc.
##

BEGIN {
  $root = "/usr/local/www/scenix.com/ews4sxs2";
  die "Invalid root directory '$root'\n" unless -d $root;
  unshift(@INC, "$root/perllib");
}

$| = 1;

require 'architextConf.pl';
require 'architext_query.pl';
require 'architext_map.pl';
require 'architext.pl';

%form = &Architext'readFormArgs;
$db = $form{'db'};
%attr = &ArchitextConf'readConfig("$root/Architext.conf", $db);
$croot = $attr{'CollectionRoot'};

open(TMP, ">$croot.progress");
close(TMP);

$status = &ArchitextQuery'createURLFiles($root, $db, %attr);
if ($status == -1) {
  unlink "$croot.progress";
  unlink "$croot.url.idx";
  unlink "$croot.url.map";
  unlink "$croot.sum.idx";
  unlink "$croot.sum.map";

  print "Content-Type: text/plain\n\n";
  print "FAILED building url files\n";
  exit(1);
};

$sysstr = "$root/createSummaryFiles -R $croot";
$sysstr = &convert_file_names($sysstr);
$status = system($sysstr);

if ($status) {
  unlink "$croot.progress";
  unlink "$croot.url.idx";
  unlink "$croot.url.map";
  unlink "$croot.sum.idx";
  unlink "$croot.sum.map";

  print "Content-Type: text/plain\n\n";
  print "FAILED building summary files ($status)\n";
  exit(1);
}

unlink "$croot.progress";

print "Content-Type: text/plain\n\n";
print "FINISHED\n";
exit(0);



