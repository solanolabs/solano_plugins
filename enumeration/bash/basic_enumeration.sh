#!/bin/bash

# Find files matching the pattern (substitute your own pattern here)
file_list=$(find . -type f -not -path '*/\.*' | grep -o "\(spec\|test\)\/.*\.rb")

if [[ $? != 0 ]]; then
  echo "No files found matching pattern."
  exit 1
elif [[ $file_list ]]; then
  echo "\n FILE LIST"
  echo $file_list
else
  echo "No files found matching pattern."
  exit 1
fi

# Format the pattern in $file_list into the JSON that Solano CI requires for custom enumeration
formated=$(echo "$file_list" | awk ' BEGIN { ORS = ""; print "{@tests@:["; } { print "@"$0"@"; } END { print "]}"; }' )
echo "\n START OF FORMAT"
echo $formated
json=$(echo $formated | sed -e "s/@@/@\, @/g" -e "s/@/\"/g")
echo "\n JSON"
echo $json
echo $json > test_list.json
