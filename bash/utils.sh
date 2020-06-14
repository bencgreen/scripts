#!/bin/bash

# THE MIT LICENSE (MIT)
#
# Copyright © 2020 bcg|design
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the “Software”), to deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit
# persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
# Software.
#
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
# WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


# ======================================================================================================================
# FUNCTIONS - ECHO & PRINT
# ======================================================================================================================

# echo 'done' - in green to stdout, and to log file
echo_done () {

  # colour commands
  GREEN='\033[1;32m'
  NC='\033[0m'

  # echo
  echo -e "${GREEN}done${NC}"
  echo "done" >> "$LOG"

}

# echo to stdout and log file, without newline terminator
#   1: string to echo
e () { 

  # get current date / time
  printf -v date '%(%Y-%m-%d %H:%M)T' -1

  # echo with date / time
  echo -e "$date $1...\c" 2>&1 | tee -a "$LOG";

}

# indent and print a string to the log file
#   1: string to print
p () { [[ ! -z "$1" ]] && SANITISED="$1" | printf "\n$SANITISED\n" | sed 's/^/  /' >> "$LOG"; }


# ======================================================================================================================
# FUNCTIONS - CLEANUP
# ======================================================================================================================

# delete files older than a specified number of days
#  1: description of files to delete (e.g. log)
#  2: number of days
#  3: directory to search
delete_old_files () {

  # only delete if days is greater than zero
  if [ "$2" -gt 0 ] ; then

    # use arguments to delete old files
    e "Deleting $1 files older than $2 days"
    DELETED=$(find "$3" -type f -mtime +$2 -delete)
    p "$DELETED"

    # done
    echo_done

  fi

}

# delete sub-directories (and contents) older than a specified number of days
#  1: description of directories to delete (e.g. backup)
#  2: number of days
#  3: root directory to search - DO NOT end with trailing slash ("/*" will be added automatically)
delete_old_dirs () {

  # only delete if days is greater than zero
  if [ "$2" -gt 0 ] ; then

    # use arguments to delete old directories
    e "Deleting $1 directories older than $2 days"
    DELETED=$(find $3/* -type d -mtime +$2 | xargs rm -rf)
    p "$DELETED"

    # done
    echo_done

  fi

}