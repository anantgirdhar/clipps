#!/bin/sh

# delbad.sh
# Open sxiv with the jpgs in a directory.
# Allow the user to mark files and store the filenames on disk.
# Have the user verify the filenames are correct.
# Then delete the appropriate jpg and raw files.

CreateDelList() {
  echo "Opening sxiv."
  echo "Mark the pictures to delete."
  echo "Filenames will be stored to disk."
  echo "After verification, jpgs and corresponding raw files will be deleted."
  echo "Press enter to continue..."
  read
  sxiv -o jpgs/* >dellist
}

jpgs_list=$(ls jpgs/*)
[ -z "$jpgs_list" ] && echo "No jpgs found." && exit 1

if [ -f dellist ]; then
  echo "Delete list already exists."
  echo "Use existing dellist? [y|N]"
  read response
  if ! ( [ "$response" = "y" ] || [ "$response" = "Y" ] ); then
    rm dellist
    CreateDelList
  fi
else
  CreateDelList
fi

[ ! -f dellist ] && echo "No dellist found. Exiting." && exit 3
[ -z "$(cat dellist)" ] && echo "No files in dellist. Exiting." && rm dellist && exit 0

echo "Opening dellist."
echo "Double check that the pictures are the ones that need to be deleted."
echo "Press enter to continue..."
read
cat dellist | sxiv -i

echo "Confirm: delete all jpgs and raw files in the dellist? [y|N]"
read response
if [ "$response" = "y" ] || [ "$response" = "Y" ]; then
  for jpgfile in $(cat dellist); do
    rm "$jpgfile"
    rawfile=$(echo "$jpgfile" | sed 's/^jpgs/raw/; s/.JPG$/.NEF/')
    [ -f "$rawfile" ] && rm "$rawfile"
  done
  rm dellist
fi
