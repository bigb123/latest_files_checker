# latest_files_checker

Script to analyze if there are new files in given folders. If so - creates symbolic links to them in given folder

    Usage:
    ./check_files.sh -l path [-t time] [-i path] path_to_folder path_to_folder2...

    Where:
      -l path - path to folder with symlinks
      -t time - (optional) how old the file can be (in seconds). Default - about one month
      -i path - path to folder or file which will be ignored (can be used multiple times) - to be implemented


I have created it to use it with [cherrymusic] (http://fomori.org/cherrymusic/ "Cherrymusic open source music server") server - I am adding new music from time to time. I want to have symbolic links to latest files located in different folders in one folder.

It is just an example. Script can be used everywhere.

## ToDo:
- ignore folders
- useful logging