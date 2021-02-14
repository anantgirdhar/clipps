# Pic Proc Scripts

Scripts to help process pictures

## split_src_folder.sh

Open sxiv with the jpgs in a source directory to create a list of files that
should be in a separate directory (album). This should be useful if the folder
on the camera was not changed.

## sortpix.sh

Sort pictures from their source folders by splitting them into nested
year/month/day subdirectories.

## delbad.sh

Open sxiv with the jpgs in a directory to create a list of files that are
straight up bad. Have the user mark images to be deleted. The file names will
be stored in a file. Have the user verify that the filenames are accurate and
then delete both jpgs and raw files.
