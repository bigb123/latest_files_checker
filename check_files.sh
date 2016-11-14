#!/bin/bash
#
# Script to check latest files in folder and creating symlinks to them in another folder
#
#
# ToDO:
# - parameters:
#  - except folders
#  - folders to analyze

PATH_TO_ANALYZE=$1 # probably /usr/local/music
PATH_WITH_SYMLINKS="/usr/local/music/latest/"
SECONDS_IN_MONTH=2360591 # amount of seconds in star month: 27 days 7 hours 43 minutes and 11 seconds

# check how old the file is: 
# - if file is newer than given value create symlink if not exist
# - if not - delete symlink if exist

function create_symlink {
  filepath="$1"
  # checking if symlink already exist
  # if not exist -create
  local filename=$(basename "$filepath")
  if [ ! -h "$PATH_WITH_SYMLINKS/$filename" ]; then
    ln -s "$1" "$PATH_WITH_SYMLINKS"
    echo "symlink created"
  fi
}

# need to do better performance - no need to check every time if symlink exists
# better go through folder with symlinks and remove old
function remove_symlink {
  filepath="$1"
  # checking if symlink already exist
  # if not exist -create
  local filename=$(basename "$filepath")
  # need to check if symlink exist; file name required; use "basename"
  if [ -h "$PATH_WITH_SYMLINKS/$filename" ]; then
    unlink "$PATH_WITH_SYMLINKS/$filename"
    echo "symlink removed"
  fi
}

function check_file_age {
  #  difference between current amount of seconds since epoch and file amount of second since epoch since last data modification 
  if [ $(( $(date +%s) - $(stat --printf "%Y" "$1") )) -lt "$SECONDS_IN_MONTH" ]; then 
    create_symlink "$1"
  else 
    remove_symlink "$1"
  fi
}


# finds reular files in given path and write it to array
find "/usr/local/music/deep house" -type f -print0 ! -path "/usr/local/music/latest/*" | while IFS= read -r -d $'\0' FileName ; do
  check_file_age "$FileName"
done

#echo $filepath_array

#for a in ; do
#  echo "akuku $a"
#done
#| xargs -0 --replace=FileName check_file_age FileName


