#!/bin/sh

#### BEGIN CONFIGURATION ####

# set dates for backup rotation
NOWDATE=`date +%Y%m%d`
LASTDATE=$(date +%Y%m%d --date='4 weeks ago')

# set backup directory variables
SRCDIR='/root/s3backups'
DESTDIR='domain.com'
BUCKET='BackupBucket'

#### END CONFIGURATION ####

# make the temp directory if it doesn't exist
mkdir -p $SRCDIR

# repair, optimize, and dump each database to its own sql file
for DB in $(mysql -BNe 'show databases' | grep -Ev 'test|mysql|information_schema|performance_schema')
do
mysqldump --quote-names --create-options --add-drop-table --force $DB > $SRCDIR/$DB.sql
mysqlcheck --auto-repair --optimize $DB
done

# tar all the databases into $NOWDATE-backups.tar.gz
cd $SRCDIR
tar -czPf $NOWDATE-db-backup.tar.gz *.sql

# upload backup to s3
s3cmd put $SRCDIR/$NOWDATE-db-backup.tar.gz s3://$BUCKET/$DESTDIR/

# delete old backups from s3
s3cmd del --recursive s3://$BUCKET/$DESTDIR/$LASTDATE-db-backup.tar.gz

# remove all files in our source directory
cd
rm -f $SRCDIR/*
