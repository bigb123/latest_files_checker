#!/usr/bin/env bash
#
# Script to check latest files in folder and create symlinks to them in given folder
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
# $1 file path
function create_symlink {
  local FilePath="$1"
  local FileName=$(basename "$FilePath")
  # checking if symlink already exist
  # if not - create
  if [ ! -h "$PATH_WITH_SYMLINKS/$FileName" ]; then
    ln -s "$FilePath" "$PATH_WITH_SYMLINKS"
    echo "Symlink created"
  fi
}

# checks if file exist and is not too old
# $1 - file path
function good_file_age {
  local FilePath="$1"
  if [ ! -e "$FilePath" ]; then
    # file doesn't exist
    echo "$FilePath: File doesn't exist"
    return 2

  #  difference between current amount of seconds since epoch and file amount of second since epoch since last data modification 
  if [ $(( $(date +%s) - $(stat --printf "%Y" "$FilePath") )) -lt "$SECONDS_IN_MONTH" ]; then 
    # create symlink
    echo "$FilePath: Age is ok"
    return 0 
  else
    # don't create symlink
    echo "$FilePath: Too old"
    return 1
  fi
}

# script usage description
function usage {
  echo
  echo "Script to check latest files in folder and create symlinks to them in given folder"
  echo 
  echo "Usage:"
  echo "$0 -l path -t time folder_to_analyze folder_to_analyze2..."
  echo
  echo "-l path - path to folder with symlinks"
  echo "-t time )in seconds) - how old the file can be"
}

while getopts ":l:t:"


# first of all go through all files in PATH_WITH_SYMLINKS and remove old ones
# explanation: http://stackoverflow.com/questions/18217930/while-ifs-read-r-d-0-file-explanation/18218019 - btw need to understand it
find "$PATH_WITH_SYMLINKS" -type l -print0  | while IFS= read -r -d $'\0' FilePath ; do
  good_file_age "$FilePath" || unlink "$PATH_WITH_SYMLINKS/$(basename $FilePath)"
done

# then go through all files in given folder and if file is not too old use create_symlink function
find "/usr/local/music/deep house" -type f -print0 ! -path "/usr/local/music/latest/*" | while IFS= read -r -d $'\0' FilePath ; do
  good_file_age "$FilePath" && create_symlink "$FilePath"
done

