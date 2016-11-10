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

# loop over all files

# if the file is older than a month the symlink will be created

# check how old the file is: 
#  difference between current amount of seconds since epoch and 
echo $(( $(date +%s) - $(stat --printf "%Y" "$file") ))

