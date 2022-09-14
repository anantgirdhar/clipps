#!/bin/sh

# Generate a new file name like:
# timestamp_device_photographer.ext
# The files will then show up in order even from multiple devices and can
# possibly be filtered a little easier
f="$1"
photographer="$2"
fallbackDeviceCode="$3"
[ -z "$f" ] && echo "No filename specified. Aborting." && exit 1
[ -z "$photographer" ] && echo "No photographer specified. Aborting." && exit 1

mimetype=$(exiftool -s3 -mimetype "$f")
case "$mimetype" in
  "image/jpeg"|"image/x-nikon-nef")
    make=$(exiftool -s3 -make "$f")
    device=$(exiftool -s3 -model "$f")
    date=$(exiftool -s3 -d "%y%m%d" -createdate "$f")
    time=$(exiftool -s3 -d "%H%M%S" -createdate "$f")
    ;;
  "video/quicktime"|"video/mp4")
    make=$(exiftool -s3 -make "$f")
    device=$(exiftool -s3 -model "$f")
    date=$(exiftool -s3 -d "%y%m%d" -createdate "$f")
    time=$(exiftool -s3 -d "%H%M%S" -createdate "$f")
    ;;
  *)
    echo "No instructions for $mimetype. Aborting."
    exit 10
    ;;
esac

# Get the device code
case "$make,$device" in
  "NIKON CORPORATION,NIKON D3200")
    deviceCode="ND3200" ;;
  "NIKON CORPORATION,NIKON D5600")
    deviceCode="ND5600" ;;
  "Apple,iPhone 6")
    deviceCode="i6" ;;
  "Apple,iPad (6th generation)")
    deviceCode="ipad6" ;;
  "SONY,ILCE-6000")
    deviceCode="Si6k" ;;
  "SONY,ILCE-7M3")
    deviceCode="Si7M3" ;;
  "Canon,Canon EOS REBEL T3i")
    deviceCode="CT3i" ;;
  "Canon,Canon PowerShot S110")
    deviceCode="CPS110" ;;
  "HTC,HTC Explorer A310e")
    deviceCode="HTCxA310" ;;
  "LGE,Nexus 5X")
    deviceCode="Nx5x" ;;
  *)
    if [ ! -z "$fallbackDeviceCode" ]; then
      deviceCode="$fallbackDeviceCode"
    else
      echo "Device code not found for $make,$device ($f). Aborting." && exit 20
    fi
    ;;
esac

# Verify timestamp
[ -z "$date" ] && echo "Unable to extract date for $f. Aborting." && exit 21
[ -z "$time" ] && echo "Unable to extract time for $f. Aborting." && exit 22

# Split out the directory and filename
directory=$(dirname "$f")
filename=$(basename "$f")
# Get the file extension
ext=${filename##*.}

newName=$date"_"$time"_"$deviceCode"_"$photographer"."$ext

echo "$newName"
