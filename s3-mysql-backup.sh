#!/bin/sh

#### s3-mysql-backup.sh  ####
#### BEGIN CONFIGURATION ####

# set dates for backup rotation
NOWDATE=$(date +%Y%m%d)
LASTDATE=$(date +%Y%m%d --date='4 weeks ago')

# set backup directory variables
MYUSER=""
MYPASS=""
SRCDIR="/home/turbowebs/s3backups"
DESTDIR="$1/db"
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

# repair, optimize, and dump each database to its own sql file
for DB in $(mysql -u $MYUSER -p$MYPASS -BNe 'show databases' | grep -Ev 'test|mysql|information_schema|performance_schema')
do
mysqldump -u $MYUSER -p$MYPASS --quote-names --create-options --add-drop-table --force "$DB" > "$SRCDIR/$DB.sql"
mysqlcheck -u $MYUSER -p$MYPASS --auto-repair --optimize "$DB"
done

# tar all the databases into $NOWDATE-backups.tar.gz
cd $SRCDIR || exit
tar -czPf "$NOWDATE-db-backup.tar.gz" ./*.sql

# upload backup to s3
aws s3 cp "$NOWDATE-db-backup.tar.gz" "s3://$BUCKET/$DESTDIR/"

# delete old backups from s3
aws s3 rm "s3://$BUCKET/$DESTDIR/$LASTDATE-db-backup.tar.gz"

# remove all files in our source directory
rm -f $SRCDIR/*
