#!/usr/bin/env bash
#
# Script to check latest files in folder and creating symlinks to them in another folder
#
#
# ToDO:
# - parameters:
#  - except folders
#  - folders to analyze

PATH_TO_ANALYZE=$1 # will be array in the future; now probably /usr/local/music
PATH_WITH_SYMLINKS="/usr/local/music/latest/"
SECONDS_IN_MONTH=2360591 # amount of seconds in star month: 27 days 7 hours 43 minutes and 11 seconds https://en.wikipedia.org/wiki/Lunar_month#Sidereal_month

# check how old the file is: 
# - if file is newer than given value create symlink if not exist
# - if not - delete symlink if exist

function create_symlink {
  local FilePath="$1"
  # checking if symlink already exist
  # if not exist -create
  local FileName=$(basename "$FilePath")
  if [ ! -h "$PATH_WITH_SYMLINKS/$FileName" ]; then
    ln -s "$FilePath" "$PATH_WITH_SYMLINKS"
    echo "Symlink created"
  fi
}

# checks if file is not too old
function good_file_age {
  #  difference between current amount of seconds since epoch and file amount of second since epoch since last data modification 
  if [ $(( $(date +%s) - $(stat --printf "%Y" "$1") )) -lt "$SECONDS_IN_MONTH" ]; then 
    echo "Age is ok"
    return 0 #create_symlink "$1"
  else
    echo "Too old"
    return 1
  fi
}

# first of all go through all files in PATH_WITH_SYMLINKS and remove old ones
# explanation: http://stackoverflow.com/questions/18217930/while-ifs-read-r-d-0-file-explanation/18218019 - btw need to understand it
find "$PATH_WITH_SYMLINKS" -type l -print0  | while IFS= read -r -d $'\0' FilePath ; do
  good_file_age "$FilePath" || unlink "$PATH_WITH_SYMLINKS/$(basename $FilePath)"
done

# then go through all files in given folder and if file is not too old use create_symlink function
find "/usr/local/music/deep house" -type f -print0 ! -path "/usr/local/music/latest/*" | while IFS= read -r -d $'\0' FilePath ; do
  good_file_age "$FilePath" && create_symlink "$FilePath"
done

