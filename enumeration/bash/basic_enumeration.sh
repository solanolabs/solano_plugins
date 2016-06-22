#!/bin/sh
set -e


file_list=$(find . -type f -not -path '*/\.*' | grep -o "\(spec\|test\)\/.*\.rb")
echo "\n FILE LIST"
echo $file_list
formated=$(echo "$file_list" | awk ' BEGIN { ORS = ""; print "{@tests@:["; } { print "@"$0"@"; } END { print "]}"; }' )
echo "\n START OF FORMAT"
echo $formated
json=$(echo $formated | sed -e "s/@@/@\, @/g" -e "s/@/\"/g")
echo "\n JSON"
echo $json
echo $json > test_list.json

