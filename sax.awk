#!/usr/bin/awk -f
#
# sax.awk
#
# Find sections and rows containing a match in documents and optionally return a single
# row.
#
# Search
# usage: awk -f sax.awk -v search=grep ~/org/commands.org $HISTFILE
#
# Get line
# usage: awk -f sax.awk -v search=grep -v selected_line=175 ~/org/commands.org $HISTFILE
#
function is_org_file()      { return FILENAME ~ /.*\.org/ }
function is_heading()       { return $1 ~ /^\*.*/ }
function is_line_match()    { return $0 ~ search }
function remove_comment(n)  { gsub(/#[ \t]+.*$/, "", saves[n]) }
function trim(n)            { gsub(/^[ \t]+|[ \t]+$/, "", saves[n]) }

is_org_file() && $1 == header_level && header_match   { header_match=0 }
is_org_file() && is_heading()  && is_line_match()     { header_match=1; header_level=$1 }
is_org_file() && !header_match && is_line_match()     { docopy=1 }
is_org_file() && is_heading()  && docopy              { for (c in cache) { saves[c]=cache[c] }; }
is_org_file()                                         { if (header_match) { saves[NR]=$0 } else { cache[NR]=$0 } }
is_org_file() && is_heading()                         { docopy=0 ; delete cache; cache[NR]=$0 }

!is_org_file() && is_line_match()                     { saves[NR]=$0 }

END {
    if (length(saves) == 0) {  # No matches found
        exit 1
    }
    else if (selected_line && !(selected_line in saves == 1)) {  # Selected line is not in saves
        exit 2
    }
    else if (selected_line && (selected_line in saves == 1)) {
        remove_comment(selected_line)
        trim(selected_line)
        printf("%s", saves[selected_line])
    }
    else {
        if (docopy) {
            for (c in cache) { saves[c]=cache[c] }
        }
        for (s in saves) {
            printf("%s | %s\n", s, saves[s])
        }
    }
}
