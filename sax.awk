#!/usr/bin/awk -f
#
# sax.awk
#
# Find sections or a specific line in an org document.
#
# Search
# usage: awk -f sax.awk -v search=grep ~/org/commands.org
#
# Get line
# usage: awk -f sax.awk -v search=grep -v selected_line=175 ~/org/commands.org

function is_heading()       { return $1 ~ /^\*.*/ }
function is_line_match()    { return $0 ~ search }
function trim(n)            { gsub(/^[ \t]+|[ \t]$+/, "", saves[n]) }

$1 == header_level && header_match   { header_match=0 }
is_heading()  && is_line_match()     { header_match=1; header_level=$1 }
!header_match && is_line_match()     { docopy=1 }
is_heading()  && docopy              { for (c in cache) { saves[c]=cache[c] }; }
                                     { if (header_match) { saves[NR]=$0 } else { cache[NR]=$0 }}
is_heading()                         { docopy=0 ; delete cache; cache[NR]=$0}

END { if (selected_line) {
        trim(selected_line)
        printf("%s", saves[selected_line]) }
      else {
        if (docopy)
          { for (c in cache) { saves[c]=cache[c] }}
        for (s in saves)
          { print s, saves[s]}}}
