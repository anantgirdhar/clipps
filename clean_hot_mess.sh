#!/bin/sh

f="$1"
echo "$f"
date=$(exiftool -createdate -d "%Y%m%d%H%M%S" "$f")
if [ ! -z "$date" ]; then
  date=$(echo "$date" | awk -F ':' '{print $2}' | tr -d ' ')
  newName="$date"."${f#*.}"
  [ ! -f "$newName" ] && mv "$f" "$newName"
fi
