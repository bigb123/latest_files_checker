#!/usr/bin/env bash
#
# Script to check latest files in folder and create symlinks to them in given folder
#
#
# ToDO:
# - ignore folders
# - logging to STDOUT, STDERR

# Error codes:
OPT_ERR=1
UNKNOWN_ERR=255


# Globals:
unset PATH_WITH_SYMLINKS
unset FILE_AGE                          
unset IGNORE_PATHS_AND_FILES # ignore files or files inside paths - to be implemeted
unset LOGPATH


# Constants:
# default value for how old the file can be
SECONDS_IN_MONTH=2360591 # amount of seconds in star month: 27 days 7 hours 43 minutes and 11 seconds - https://en.wikipedia.org/wiki/Lunar_month#Sidereal_month
LOGPATH="$(dirname $(readlink -f $0))/event,log"


# usage description
usage () {
  echo
  echo "Script to check latest files in folder and create symlinks to them in given folder"
  echo 
  echo "Usage:"
  echo "$0 -l path [-t time] [-i path] path_to_folder path_to_folder2..."
  echo
  echo "Where:"
  echo "  -l path - path to folder with symlinks"
  echo "  -t time - (optional) how old the file can be (in seconds). Default - about one month"
  echo "  -i path - path to folder or file which will be ignored (can be used multiple times) - to be implemented"
  echo
}


# check how old the file is: 
# - if file is newer than given value create symlink if not exist
# - if not - delete symlink if exist
# $1 - file path
create_symlink () {
  local FilePath="$1"
  local FileName=$(basename "$FilePath")
  # checking if symlink already exist
  # if not - create
  if [ ! -h "$PATH_WITH_SYMLINKS/$FileName" ]; then
    ln -s "$FilePath" "$PATH_WITH_SYMLINKS"
    echo "$FilePath : Symlink created"
  fi
}


# checks if file exist and is not too old
# $1 - file path
good_file_age () {
  local FilePath="$1"
  if [ ! -e "$FilePath" ]; then
    # file doesn't exist
    echo "$FilePath : File doesn't exist"
    return 2
  fi

  #  difference between current amount of seconds since epoch and file amount of second since epoch since last data modification 
  if [ $(( $(date +%s) - $(stat --printf "%Y" "$FilePath") )) -lt "$FILE_AGE" ]; then 
    # create symlink
    echo "$FilePath : Age is ok: $(stat --printf "%Y" "$FilePath") max $FILE_AGE"
    return 0 
  else
    # don't create symlink
    echo "$FilePath : Too old: $(stat --printf "%Y" "$FilePath") max $FILE_AGE"
    return 1
  fi
}


#######    MAIN    #########
main () {
  if [ $# -eq 0 ]; then
    usage
    exit "$OPT_ERR"
  fi


  IGNORE_PATHS_AND_FILES=()

  while getopts ":l:t:i:" optname; do
    case "$optname" in
      "l")
        #echo "Path to folder where the links will be stored: $OPTARG"
        # check if last character in path is slash '/'
        # this spaghetti in IF takes last character from OPTARG
        # explanation: http://www.ibm.com/developerworks/library/l-bash-parameters/index.html
        if [ "/" == ${OPTARG:((${#OPTARG}-1)):1} ]; then
          PATH_WITH_SYMLINKS="$OPTARG"
        else
          PATH_WITH_SYMLINKS="$OPTARG/"
        fi
      ;;
      "t")
        echo "How old the file can be: $OPTARG"
        FILE_AGE="$OPTARG"
      ;;
      "i")
        IGNORE_PATHS_AND_FILES+="$OPTARG"
      ;;
      ":")
        echo "ERROR: No argument for option $OPTARG"
        usage
        exit "$OPT_ERR"
      ;;
      "?")
        echo "Unknown option"
        usage
        exit "$OPT_ERR"
      ;;
      "*")
        echo "Unknown error"
        exit "$UNKNOWN_ERR"
      ;;
    esac
  done

  # check if PATH_WITH_SYMLINKS was given
  if [ -z "$PATH_WITH_SYMLINKS" ]; then
    echo "ERROR: You need to provide -l option"
    usage
  fi

  # set default value of FILE_AGE if it wasn't given
  if [ -z "$FILE_AGE" ]; then
    FILE_AGE="$SECONDS_IN_MONTH"
  fi


  ## TO BE IMPLEMENTED
  # check if given ignore path is file or folder - if folder we need to add "/*" at the end
  for path in "${IGNORE_PATHS_AND_FILES[@]}"; do
    if [ -d "$path" ]; then
      :
    fi
  done


  # all arguments without options on the end of optstring are paths to folder 
  # ${@:$OPTIND} explanation: http://www.ibm.com/developerworks/library/l-bash-parameters/index.html
  FOLDERS_TO_ANALYZE=("${@:$OPTIND}")


  # first of all go through all files in PATH_WITH_SYMLINKS and remove old ones
  # IFS explanation: http://stackoverflow.com/questions/18217930/while-ifs-read-r-d-0-file-explanation/18218019
  find "$PATH_WITH_SYMLINKS" -type l -print0  | while IFS= read -r -d $'\0' FilePath ; do
    good_file_age "$FilePath" || ( 
      # had problems with combining basename and unlink commands so forced to creare variable
      filename=$(basename "$FilePath") && unlink "$PATH_WITH_SYMLINKS$filename" 
    ) 
    # $(filename=$(basename "$FilePath") ; echo "$PATH_WITH_SYMLINKS$filename")
    #unlink "$PATH_WITH_SYMLINKS/$(basename $FilePath)"
  done

  #echo "Folders to analyze: ${FOLDERS_TO_ANALYZE[@]}"

  # then go through all files in given folder and if file is not too old use create_symlink function
  find "${FOLDERS_TO_ANALYZE[@]}" -type f -print0 ! -path "$PATH_WITH_SYMLINKS/*" | while IFS= read -r -d $'\0' FilePath ; do
    good_file_age "$FilePath" && create_symlink "$FilePath"
  done
}


#### Run the program ####

main

