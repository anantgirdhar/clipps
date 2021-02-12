#!/bin/bash

# Logic:
# While possible, get the next subdir from source.
# Check the CreateDate for all the images.
# Split the files into raw and jpgs (create dirs if needed).
# Copy folder to a yyyy/mm folder structure.
# Rename folder to day range (separated by underscores) and a trailing underscore (so that the description can be placed after it). 
# Compare sizes of the two folders and number of files (quick copy success check).
# Rename folder to have prefix PROC

# Usage: ./sortpix.sh [source [unprocessed]]
# Default source: ./source
# Default unprocessed: ./unprocessed

trap "exit" SIGINT;

SOURCE="$1"
UNPROCESSED="$2"

# Check if a source dir has been provided
if [ -z "$SOURCE" ]; then
	SOURCE='./source'
fi

# Check if an unprocessed dir has been provided
if [ -z "$UNPROCESSED" ]; then
	UNPROCESSED='./unprocessed'
fi

# Get the list of unprocessed dirs in the unsorted dir
dirlist=`ls $SOURCE | grep --invert-match '^PROC'`

# Run until all dirs have been processed
for dir in $dirlist
do
    echo $dir
    initial_path=$SOURCE/$dir
    # Get all the unique created dates for all files in this directory
    dates=$( 
        exiftool -createdate -d "%Y*%m*%d" $initial_path/* | 
        grep -Eo '[0-9]{4}\*[0-9]{2}\*[0-9]{2}' |
        sort |
        uniq
        );
    #echo $dates

    # Get the start and end dates
    start_date=$( echo $dates | cut -d ' ' -f 1 )
    start_year=$( echo $start_date | cut -d '*' -f 1 )
    start_month=$( echo $start_date | cut -d '*' -f 2 )
    start_day=$( echo $start_date | cut -d '*' -f 3 )
    end_date=$( echo $dates | rev | cut -d ' ' -f 1 | rev )
    end_month=$( echo $end_date | cut -d '*' -f 2 )
    end_day=$( echo $end_date | cut -d '*' -f 3 )
    #echo $start_date
    #echo $start_year
    #echo $start_month
    #echo $start_day
    #echo $end_date
    #echo $end_month
    #echo $end_day

    # Split the files into jpgs and raw (create dirs if needed)
    if [ ! -d $initial_path/jpgs ]
    then
        mkdir $initial_path/jpgs
    fi
    if [ ! -d $initial_path/raw ]
    then
        mkdir $initial_path/raw
    fi
    #TODO: Move only if the files exist
    #TODO: Remove the subfolders if there are no files to put in them
    mv $initial_path/*.JPG $initial_path/jpgs/
    mv $initial_path/*.NEF $initial_path/raw/

    # If the dir for this month does not exist, create it
    if [ ! -d $UNPROCESSED/$start_year ]
    then
        mkdir $UNPROCESSED/$start_year
    fi
    if [ ! -d $UNPROCESSED/$start_year/$start_month ]
    then
        mkdir $UNPROCESSED/$start_year/$start_month
    fi

    # Create a name for the final location dir
    date_prefix=$start_day
    if [ $start_date != $end_date ]
    then
        # We need to include the final date information
        date_prefix="$date_prefix""_""$end_month""$end_day"
    fi
    final_dir_name="$date_prefix""_""$dir"
    final_path=$UNPROCESSED/$start_year/$start_month/$final_dir_name
    
    echo "Copying from $initial_path to $final_path."
    # Sort files and rename dirs based on date
    rsync -avh --progress --info=progress2 $initial_path $final_path
    # Compare sizes of initial and final
    #echo 'Initial sizes:'
    #du -s $initial_path
    #echo 'Final sizes:'
    #du -s $final_path
    proc_prefix="PROC"
    initial_size=$( echo `du -s $initial_path` | cut -d ' ' -f 1 )
    final_size=$( echo `du -s $final_path` | cut -d ' ' -f 1 )
    if [ $initial_size -ne $final_size ]; then
	echo "Error: Size mismatch."
	echo $initial_size
	echo $final_size
	#TODO: Indicate this on the directory rename too
	proc_prefix="PROC_CHECKSIZE"
    fi

    # Rename source folder to indicate it has been processed
    mv $SOURCE/$dir $SOURCE/"$proc_prefix"_$dir

    #TODO: Rename image files to some combination of device and timestamp
    #TODO: Add verbose option
    #TODO: Add dry run option
    #TODO: Take care of file name conflicts

    echo
done

