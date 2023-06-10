#!/bin/sh
# filename: files_all.cgi

echo "Content-type: Text/HTML"
echo

cd /usr/local/www/scenix.com
echo "<HTML><HEAD><TITLE>Creating file list for entire scenix.com</TITLE></HEAD>\n"
echo "<BODY BGCOLOR="#FFFFFF">\n"
echo "<H1 ALIGN=CENTER>Creating file list for entire scenix.com...Please wait...</H1>\n"
find . -name '*.html' > htmls
find . -name '*.htm' > htms
cat htmls htms > files
rm htmls htms
echo "<H2>Done.</H2>\n"
echo "</BODY></HTML>\n"
