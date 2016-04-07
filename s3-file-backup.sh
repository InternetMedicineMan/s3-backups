#!/bin/sh

#### s3-file-backup.sh ####
#### BEGIN CONFIGURATION ####

# set dates for backup rotation
NOWDATE=$(date +%Y%m)
LASTDATE=$(date +%Y%m --date='2 months ago')

# set backup directory variables
BACKUP="/home/turbowebs/webapps"
SRCDIR="/home/turbowebs/s3backups"
DESTDIR="$1/file"
BUCKET="TurboBackups"

#### END CONFIGURATION ####

# check a parameter was sent
if [ -z "$1" ]
then
    echo "Please include directory to backup as parameter"
    exit
fi

# make the temp directory if it doesn't exist
mkdir -p $SRCDIR

# generate file backup of the public_html directory
cd $BACKUP || exit
tar -czf "$SRCDIR/$NOWDATE-file-backup.tar.gz" "$1"
cd $SRCDIR || exit

# upload backup to s3
aws s3 cp "$SRCDIR/$NOWDATE-file-backup.tar.gz" "s3://$BUCKET/$DESTDIR/"

# delete old backups from s3
aws s3 rm "s3://$BUCKET/$DESTDIR/$LASTDATE-file-backup.tar.gz"

# remove all files in our source directory
rm -f $SRCDIR/*
