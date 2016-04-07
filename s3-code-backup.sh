#!/bin/sh

#### s3-code-backup.sh ####
#### BEGIN CONFIGURATION ####

# set dates for backup rotation
NOWDATE=$(date +%Y%m%d)
LASTDATE=$(date +%Y%m%d --date='2 weeks ago')

# set backup directory variables
BACKUP="/home/turbowebs/webapps"
SRCDIR="/home/turbowebs/s3backups"
DESTDIR="$1/code"
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

# generate code backup of the public_html directory
cd $BACKUP || exit
tar -czf "$SRCDIR/$NOWDATE-code-backup.tar.gz" --exclude-tag-under=tagfile-diehl "$1"
cd $SRCDIR || exit

# upload backup to s3
aws s3 cp "$SRCDIR/$NOWDATE-code-backup.tar.gz" "s3://$BUCKET/$DESTDIR/"

# delete old backups from s3
aws s3 rm "s3://$BUCKET/$DESTDIR/$LASTDATE-code-backup.tar.gz"

# remove all files in our source directory
rm -f $SRCDIR/*
