#! /bin/sh

#### BEGIN CONFIGURATION ####
# This backup is designed to backup all the WordPress code
# just add a file matching tagfile name to directories to skip

# set dates for backup rotation
NOWDATE=`date +%Y%m%d`
LASTDATE=$(date +%Y%m%d --date='2 weeks ago')

# set backup directory variables
SRCDIR='/root/s3backups'
DESTDIR='domain.com'
BUCKET='BackupBucket'

#### END CONFIGURATION ####

# make the temp directory if it doesn't exist
mkdir -p $SRCDIR

# generate code backup of the webroot directory
cd /home/
tar -czf $NOWDATE-code-backup.tar.gz --exclude-tag-under=tagfile-diehl public_html/
mv $NOWDATE-code-backup.tar.gz $SRCDIR
cd $SRCDIR

# upload backup to s3
s3cmd put $SRCDIR/$NOWDATE-code-backup.tar.gz s3://$BUCKET/$DESTDIR/

# delete old backups from s3
s3cmd del --recursive s3://$BUCKET/$DESTDIR/$LASTDATE-code-backup.tar.gz

# remove all files in our source directory
cd
rm -f $SRCDIR/*
