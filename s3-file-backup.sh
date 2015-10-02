#!/bin/sh

#### BEGIN CONFIGURATION ####

# set dates for backup rotation
NOWDATE=`date +%Y%m`
LASTDATE=$(date +%Y%m --date='2 months ago')

# set backup directory variables
SRCDIR='/root/s3backups'
DESTDIR='domain.com'
BUCKET='BackupBucket'

#### END CONFIGURATION ####

# make the temp directory if it doesn't exist
mkdir -p $SRCDIR

# generate code backup of the public_html directory
cd /home/
tar -czf $NOWDATE-file-backup.tar.gz public_html/
mv $NOWDATE-file-backup.tar.gz $SRCDIR
cd $SRCDIR

# upload backup to s3
s3cmd put $SRCDIR/$NOWDATE-file-backup.tar.gz s3://$BUCKET/$DESTDIR/

# delete old backups from s3
s3cmd del --recursive s3://$BUCKET/$DESTDIR/$LASTDATE-file-backup.tar.gz

# remove all files in our source directory
cd
rm -f $SRCDIR/*
