#!/bin/bash
#
# Script to check latest files in folder and creating symlinks to them in another folder
#
#
# Parameters:
# 1 - path to folder to analyze
# except folders

PATH_TO_ANALYZE=$1 # probably /usr/local/music
SECONDS_IN_MONTH=2360591 # amount of seconds in star month: 27 days 7 hours 43 minutes and 11 seconds

function create_symlink {
  echo "Create"
}


# find deals with decision stuff: 
# - if file is newer than month create symlink if not exist
# - if not - delete symlink if exist

find "/usr/local/music/deep house" -type f ! -path "/usr/local/music/latest/*" -exec bash -c '
  echo "{}"
  # check how old the file is: 
  #  difference between current amount of seconds since epoch and file amount of second since epoch since last data modification 
  if [ $(( $(date +%s) - $(stat --printf "%Y" "{}") )) -lt $0 ]; then
    $1
  else 
    echo "old"
  fi
' $SECONDS_IN_MONTH create_symlink \;

