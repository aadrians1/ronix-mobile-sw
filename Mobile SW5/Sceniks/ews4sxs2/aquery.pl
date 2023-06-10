#!/bin/sh
perl=/usr/local/www/scenix.com/ews4sxs2/perl
eval "exec $perl -x $0 $1 '$2'"
#!perl

## Copyright (c) 1996 Excite, Inc.
##
## This program is a flexible wrapper for the query program. For
## maximum efficiency, you might want to invoke the executable
## directly, pointing it to the proper info file with "-C".
BEGIN {
  $root = "/usr/local/www/scenix.com/ews4sxs2";
  $ENV{"LD_LIBRARY_PATH"} = ($ENV{"LD_LIBRARY_PATH"} ?
			     ($ENV{"LD_LIBRARY_PATH"}.":") : "").$root;
  unshift(@INC, "$root/perllib");
}

require 'architextConf.pl';
require 'os_functions.pl';

$database = shift;
die "Must specify database" unless $database;

$query = "@ARGV";
if ($query !~ /^\(/) {
    $query = "(concept $query)";
}

## Read the configuration file, and possibly make a CollectionInfo
## file.
%attr = &ArchitextConf'readConfig("$root/Architext.conf", $database);

$attr{'CollectionInfo'} ||
    die "Configuration file must specify CollectionInfo file\n";

if (! -e $attr{'CollectionInfo'}) {
    print STDERR "Creating CollectionInfo file '$attr{'CollectionInfo'}'\n";
    &ArchitextConf'makeInfoFile(%attr);
    die "Failed to create CollectionInfo file"
	unless -e $attr{'CollectionInfo'};
}

$attr{'SearchExecutable'} ||
    die "Configuration file must specify SearchExecutable\n";

$searcher = &ArchitextConf'makeAbsolutePath($attr{'SearchExecutable'},
					    $attr{'ArchitextRoot'});

die "SearchExecutable '$searcher' does not exist or is not really exectuable\n"
    if (! &executable($searcher));

## Run the search program now that we have all the options set up.
$qcommand = "$searcher -C $attr{'CollectionInfo'} -q \"$query\"";
$qcommand = &convert_file_names($qcommand);
system($qcommand);






