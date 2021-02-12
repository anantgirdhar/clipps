#!/bin/bash

# Logic:
# While possible, get the next subdir from unsorted. 
# Check the CreateDate for all the images.
# Split the files into raw and jpgs (create dirs if needed).
# Copy folder to yyyy/mm folder at save level as unsorted.
# Rename folder to day range (separated by underscores) and a trailing underscore (so that the description can be placed after it). 
# Compare sizes of the two folders and number of files (quick copy success check).
# Rename folder to have prefix PROC

# Usage: ./sortpix.sh unsorted_dir

UNSORTED=$1
SORTED='./'

# Check if an unsorted dir has been provided
if [ -z $UNSORTED ]
then
    echo 'No unsorted dir specified. Exiting.'
    return 1
fi

# Get the list of unprocessed dirs in the unsorted dir
dirlist=`ls $UNSORTED | grep --invert-match '^PROC'`

# Run until all dirs have been processed
for dir in $dirlist
do
    echo $dir
    initial_path=$UNSORTED/$dir
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
    if [ ! -d $SORTED/$start_year ]
    then
        mkdir $SORTED/$start_year
    fi
    if [ ! -d $SORTED/$start_year/$start_month ]
    then
        mkdir $SORTED/$start_year/$start_month
    fi

    # Create a name for the final location dir
    date_prefix=$start_day
    if [ $start_date != $end_date ]
    then
        # We need to include the final date information
        date_prefix="$date_prefix""_""$end_month""$end_day"
    fi
    final_dir_name="$date_prefix""_""$dir"
    final_path=$SORTED/$start_year/$start_month/$final_dir_name
    
    # Sort files and rename dirs based on date
    cp -r $initial_path $final_path
    # Compare sizes of initial and final
    #echo 'Initial sizes:'
    #du -s $initial_path
    #echo 'Final sizes:'
    #du -s $final_path
    proc_prefix="PROC"
    initial_size=$( echo `du -s $initial_path` | cut -d ' ' -f 1 )
    final_size=$( echo `du -s $final_path` | cut -d ' ' -f 1 )
    if [ $initial_size -ne $final_size ]
    then
        echo "Error: Size mismatch."
        echo $initial_size
        echo $final_size
        #TODO: Indicate this on the directory rename too
        proc_prefix="PROC_CHECKSIZE"
    fi

    # Rename source folder to indicate it has been processed
    mv $UNSORTED/$dir $UNSORTED/"$proc_prefix"_$dir

    #TODO: Rename image files to some combination of device and timestamp
    #TODO: Add verbose option
    #TODO: Add dry run option
    #TODO: Take care of file name conflicts

    echo
done

