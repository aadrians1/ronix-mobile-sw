## contains functions for dealing with multiple html roots
## Copyright (c) 1996 Excite, Inc.

package ArchitextMap;

## grabs mappings from URLs to filenames from a file and
## returns them in an associative array with keys being the
## filename and urls being the values
sub getMappings {
    local($htmlroot, $mapfile, $userfile) = @_;
    local(%mappings);
    $htmlroot .= "/" unless ($htmlroot =~ /\/$/);
    $mappings{$htmlroot} = "/";
    if (-e $mapfile) {
	open(MAPS, $mapfile);
	while (<MAPS>) {
	    ($url, $map) = split;
	    $mappings{$map} = $url if ($map && $url);
	}
	close(MAPS);
    }
    if ($userfile) {
	open(USER, $userfile);
	while (<USER>) {
	    ($url, $map) = split;
	    $url = "/$url/" if $url;
	    $mappings{$map} = $url if ($map && $url);
	}
	close(USER);
    }
    %mappings;
}


## returns a perl statement suitable for an eval that
## is used to transpose result list filenames to urls at search time
sub generateURLEdit {
    local(%mappings) = @_;
    local($expression, $file, $url, $current);
    foreach $file (keys %mappings) {
	$url = $mappings{$file};
	$url =~ s/\\/\//g;
	$file =~ s/[\/\\]/[\\\\\\\/]/g;
	$current = "s|$file|$url|; ";
	$expression .= $current;
    }
    $expression;
}



1;
