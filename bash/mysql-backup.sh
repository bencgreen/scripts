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


VERSION=0.1.2010201515


# ======================================================================================================================
# SET VARIABLES
# ======================================================================================================================

BACKUP_PATH=/tmp/backup
BACKUP_KEEP_FOR_DAYS=14


# ======================================================================================================================
# UTILS
# ======================================================================================================================

SCRIPT_DIR=$(dirname $0)
UTILS="$SCRIPT_DIR/utils.sh"
if [ ! -f "$UTILS" ]; then
  echo "Please create $UTILS before running this script"
  exit
fi

source "$UTILS"


# ======================================================================================================================
# GET DATABASES
# ======================================================================================================================

DATABASES=$(mysql --password=${MARIADB_ROOT_PASSWORD} --user=root -e 'show databases;' | sed 1d | grep -v -E "(mysql|information_schema|performance_schema)")

if [ "${DATABASES}" == "" ]
then
  exit
fi


# ======================================================================================================================
# GET BACKUP PATH
# ======================================================================================================================

if [ ! -d ${BACKUP_PATH} ]
then
  mkdir -p ${BACKUP_PATH}
  chmod 740 ${BACKUP_PATH}
fi


# ======================================================================================================================
# PERFORM BACKUPS TO TEMP DIR
# ======================================================================================================================

cd /tmp

for DATABASE in ${DATABASES}
do
  if [ -f /tmp/${DATABASE}.sql ]
  then
    rm -f /tmp/${DATABASE}.sql
  fi

  mysqldump --add-locks --password=${MARIADB_ROOT_PASSWORD} --user=root ${DATABASE} > /tmp/${DATABASE}.sql
done


# ======================================================================================================================
# MOVE BACKUPS TO BACKUP FOLDER AND GZIP
# ======================================================================================================================

DATE=$(date '+%Y%m%d%H%M')
mkdir -p ${BACKUP_PATH}/${DATE}
chmod 740 ${BACKUP_PATH}/${DATE}
cd ${BACKUP_PATH}/${DATE}

for DATABASE in ${DATABASES}
do
  if [ -f /tmp/${DATABASE}.sql ]
  then
    mv /tmp/${DATABASE}.sql ${DATABASE}.sql
    gzip ${DATABASE}.sql
    chmod 640 ${DATABASE}.sql.gz
  fi
done


# ======================================================================================================================
# REMOVE OLD BACKUPS
# ======================================================================================================================

delete_old_dirs "MySQL backup" ${BACKUP_KEEP_FOR_DAYS} ${BACKUP_PATH}
