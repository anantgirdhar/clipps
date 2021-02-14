#!/bin/sh

# Split a source folder
# Open jpgs in a source folder with sxiv.
# If the user marks any files, save those names to a list.
# Move those files (including associated raw files) to a new folder.
# This could be used to separate files that should have been in different
# source folders to begin with.

echo "Opening sxiv."
echo "Mark images to move to a new source folder."
echo "Press enter to continue..."
read
sxiv -o *.JPG > movelist

[ ! -f movelist ] && echo "No movelist found. Exiting." && exit 1
[ -z "$(cat movelist)" ] && echo "No files in movelist. Exiting." && rm movelist && exit 0

echo "Opening movelist."
echo "Double check that the pictures chosen are the ones that need to be moved."
echo "Press enter to continue..."
read
cat movelist | sxiv -i

echo -n "Enter a name for the new directory. Leave blank for a default name: "
read newDir

[ -z "$newDir" ] && newDir="$(basename `pwd`)_$(date +%H%M)"

mkdir "../$newDir"
for jpgfile in $(cat movelist); do
  mv "$jpgfile" "../$newDir/"
  rawfile=$(echo "$jpgfile" | sed 's/^jpgs/raw/; s/.JPG$/.NEF/')
  [ -f "$rawfile" ] && mv "$rawfile" "../$newDir/"
done
rm movelist
