## Architext perl library features list.
## Used by architext.pl to figure out which features are
## enabled.  Unless the binaries actually support the features
## enabled in the scripts, none of the advanced features will
## work

#############################################################
## USER CUSTOMIZABLE FEATURES                              ##
#############################################################
$new_query_button = 1;
$graphic_relevance_mode = 1;
$query_by_example_mode = 1;
$summary_mode = 1;
$inline_summaries = 1;
$summary_link_mode = 1;
$number_of_summary_sentences = 5;
##$maximum_summary_length = 200;
$subject_group_mode = 1;
$number_of_subject_groups = 6;
$show_additional_docs_in_grouping = 1;
$max_docs_to_return = 20;
$show_legend = 'bottom';
##$show_legend = 'top';
$customize_result_list = 0;
#$log_searches = 1;
##$maximum_query_time = 120;  ## (in seconds)
$stem_by_default = 1;
##$index_html_comments = 1;
#############################################################
##  USER CUSTOMIZABLE FUNCTIONS                            ##
#############################################################
## this function can be used to modify the results lines
## as they appear in the hit-list as presented by the
## search scripts.  This function will not be called unless
## the variable '$customize_result_list', defined above,
## is given a non-zero value.
sub customize_result_list_line {
    local($collection_name, $file, $doc_root, $relevance_qbe, $score,
	  $title, $summary, $original_line) = @_;
    return "$original_line";
}

##this function serves the same purpose as 'customize_result_list_line',
##but will instead modify the line presented after the user does
##a subject grouping.  There is no reason these functions cannot
##do the same thing, but since the html for the results after
## a query and a subject grouping are slightly different, two
##separate functions are provided.
sub customize_grouping_line {
    local($collection_name, $file, $doc_root, $relevance_qbe,  
	  $title, $summary, $original_line) = @_;
    return "$original_line";
}




################################################################
## END OF CUSTOMIZABLE SECTION                                ##
################################################################

## DO NOT change any of the values below, or you could
## cause problems with the functionality of this product

## notifier variables
$notify_icon = "AT-red_x.gif";
$notify_blank = "AT-blank_x.gif";
##$notifier_on = 1;
## end of notifier variables

#$external_sites = 1;
##$a_acro = 0;
$backlink_mode = 1;
$index_user_dirs = 1;
#$no_stemming_mode = 1;
$restrict_beneath_document_root = 1;
$custom_format = 0;
$distributed = 0;
$debugmode = 0;
$advise_on_gather = 1;
$max_docs_per_subgroup = 10;
$gather_options = "m=iavg trunc=10 fid=50 gv=50 i=2";
$script_suffix = ".cgi";

##$index_time_mapping = 1;

$productVersion = "1.1.1P1";
$help_path = "http://www.excite.com/navigate/doc/EWS1.1/";
$remoteScriptName = 
    "http://www.atext.com/cgi/ews11-start.cgi";
$news_url = "http://www.excite.com/navigate/news/news.html";

$warning_icon = "AT-redball.gif";
$error_icon = "AT-stopsign.gif";
$confidence_image = "AT-grouped_confidence.gif";
$subject_image = "AT-grouped_subject.gif";
$admin_banner = "AT-admin_banner.gif";
$install_banner = "AT-install_banner.gif";
$query_banner = "AT-search_banner.gif";
$search_button = "AT-search_button.gif";
$dualsearch_button = "AT-dual_search.gif";
$result_banner = "AT-search_banner.gif";
$results_by_graphic = "AT-results_label.gif";
$excited_ad = "AT-trans_logo.gif";

$powered_by_excite = 1;

## filenames for different relevance balls and QBE and Summary icons
## old UI graphics
%balls = (
	  '0', 'AT-blueball.gif',
	  '1', 'AT-3stars.gif',
	  '2', 'AT-2stars.gif',
	  '3', 'AT-1stars.gif',
	  '4', 'AT-1stars.gif',
	  );			

## ECO new UI graphics
%icons = (
	  '0', 'AT-blueball.gif',
	  '1', 'AT-red_x.gif',
	  '2', 'AT-black_x.gif',
	  '3', 'AT-black_x.gif',
	  '4', 'AT-black_x.gif',
	  );			













