#!/bin/sh

# Rename a bunch of files in the current folder according to EXIF data
# Files will be named something like:
# timestamp_device_photographer.ext

photographer="$1"
fallbackDeviceCode="$2"
[ -z "$photographer" ] && echo "No photographer specified. Aborting." && exit 1

for f in *; do
  if [ -z "$fallbackDeviceCode" ]; then
    newName=$(generateExifName.sh "$f" "$photographer")
  else
    newName=$(generateExifName.sh "$f" "$photographer" "$fallbackDeviceCode")
  fi
  if [ $? -eq 0 ]; then
    echo "$f -> $newName"
    mv "$f" "$newName"
  else
    echo "$f x-> $newName"
  fi
done
