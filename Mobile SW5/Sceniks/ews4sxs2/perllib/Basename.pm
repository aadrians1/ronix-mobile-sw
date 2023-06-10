# Basename.pm
#   parse file name and path from a file specification
#   calling sequence:
#     (basename,dirpath,tail) = &Basename(filespec,excludelist);
#     where  filespec    is the file specification to be parsed, and
#            excludelist is a list of patterns which should be removed
#                        from the end of basename.
#            basename    is the part of filespec after dirpath (i.e. the
#                        name of the file).  The elements of excludelist
#                        are compared to basename, and if an  
#            dirpath     is the path to the file, up to and including the
#                        end of the last directory name
#            tail        any characters removed from basename because they
#                        matched an element of excludelist.
#
#   Basename first removes the directory specification from filespec,
#   according to the syntax of the OS (code is provided below to handle
#   VMS, Unix, and MSDOS; you pick the one you want or accept the default
#   based on the information in the %Config array).  It then compares
#   each element of excludelist to basename, and if that element is the
#   suffix of basename, it is removed from basename and prepended to
#   tail.  By specifying the elements of excludelist in the right order,
#   you can 'nibble back' basename to extract the portion of interest
#   to you.
#
#   For example, on a system running Unix,
#   ($base,$path,$type) = &Basename('/virgil/aeneid/draft.book7','\.book\d+');
#   would yield $base == 'draft',
#               $path == '/virgil/aeneid', and
#               $tail == '.book7'.
#   Similarly, on a system running VMS,
#   ($name,$dir,$type) = &Basename('Doc_Root:[Help]Rhetoric.Rnh','\..*');
#   would yield $name == 'Rhetoric';
#               $dir == 'Doc_Root:[Help]', and
#               $type == '.Rnh'.
#
#   Version 2.0  26-Aug-1994  Charles Bailey  bailey@genetics.upenn.edu 

package Basename;

require 5.000;
require Config;
require Exporter;
@ISA = (Exporter);
@EXPORT = (basename);

sub basename {
  my($basename,@suffices) = @_;
  my($dirpath,$tail,$suffix,$idx);

  $fstype = $Config{'osname'} unless $fstype;

  if ($fstype =~ /VMS/i) {
    while ($basename =~ /([^\]>]*)([\]>])/) {
      $dirpath .= $1 . $2;
      $basename = $';
    }
    if (!$dirpath) {
      while ($basename =~ /([^:]*):/) {
        $dirpath .= $1 . ':';
        $basename = $';
      }
    }
  }
  elsif ($fstype =~ /MSDOS/i) {
    while ($basename =~ /([^\\]*)\\/) {
      $dirpath .= $1 . '\\';
      $basename = $';
    }
  }
  else {  # default to Unix
    while ($basename =~ m%([^/]*)/%) {
      $dirpath .= $1 . '/';
      $basename = $';
    }
  }

  if ($#suffices > -1) {
    foreach $suffix (@suffices) {
      if ($basename =~ /($suffix)$/) {
        $tail = $1 . $tail;
        $basename = $`;
      }
    }
  }

  ($basename,$dirpath,$tail);

}

1;
[Mailinglist--not acked]

