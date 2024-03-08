#!/usr/bin/env bash
if [ -z "$STORAGE_BACKUP" ]
then 
  echo "Using shell params for Storage backup"
  if [ -z "$1" ] 
  then
    echo "First param is the storage backup file to use [BEFORE ADDING .gz] ('storage.yyyy.mm.dd@hh-mm.gz')"
    exit -1
  else
    echo "Using $1.gz as storage backup file"
    STORAGE_BACKUP=$1
  fi
fi

if [ -z "$DB_BACKUP" ]
then
  echo "Using shell params for DB backup"
  if [ -z "$2" ]
  then
    echo "Second param is the db backup file to use [BEFORE ADDING.gz] ('prod.dump.yyyy.mm.dd@hh-mm.gz')"
    exit -1
  else
    echo "Using $2.gz as db backup file"
    DB_BACKUP=$2
  fi
fi

if [ -z "$DB_OUT_FILENAME" ]
then
  echo "Using shell params for DB out filename"
  if [ -z "$3" ]
  then
    echo "Third param is the db backup file to process the DB backup into. It will be placed in storage/ and will usually look like (development.db|production.db)"
    exit -1
  else
    echo "Using $3.gz as db out filename"
    DB_OUT_FILENAME=$3
  fi
fi

echo "Using $STORAGE_BACKUP as Storage backup"
echo "Using $DB_BACKUP as DB Backup"
echo "Using $DB_OUT_FILENAME as DB output filename in storage/"

DATE_AND_TIME=$(date "+%F@%H-%m")
ORIGINAL_DIR=$(pwd)
TEMPORARY_DIR=$(mktemp -d)
echo "Moving storage from storage/ to storage-pre-backup-hydration-/"
mv storage/ storage-pre-backup-hydration-$DATE_AND_TIME/

cp $STORAGE_BACKUP.gz $TEMPORARY_DIR
cp $DB_BACKUP.gz $TEMPORARY_DIR
cd $TEMPORARY_DIR

gzip -dk $STORAGE_BACKUP.gz
tar -xvf $STORAGE_BACKUP --strip-components=3

gzip -dk $DB_BACKUP.gz
sqlite3 backup-output.db < $DB_BACKUP

mv backup-output.db storage/$DB_OUT_FILENAME
mv storage/ $ORIGINAL_DIR/storage

echo "Backup complete. storage/ has the hydrated files now"

