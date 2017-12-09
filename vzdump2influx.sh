#!/bin/bash
#Just a simple script to wtite some stats to InfluxDB about your backup. Based on vzdump hook method.
DBUSER=<DBUSER>
DBPASS=<DBPASS>
DBHOST=<DBHOST>
DBPORT=<DBPORT>
DBNAME=<DBNAME>
LOCATIONCODE=<LOCATION_CODE>

if [ "$1" == "backup-start" ]; then
    echo `date +%s` > /tmp/backup-info
    echo $HOSTNAME >> /tmp/backup-info
fi
if [ "$1" == "backup-end" ]; then
    DURATION=$((`date +%s`-`sed '1q;d' /tmp/backup-info`))
    /usr/bin/curl -s -i -XPOST -u $DBUSER:$DBPASS "http://$DBHOST:$DBPORT/write?db=$DBNAME" --data-binary  "backup_px,host=$HOSTNAME,location=$LOCATIONCODE success=1,duration=$DURATION,size=`stat -c%s $TARFILE`" > /dev/null
    rm /tmp/backup-info
fi
if [ "$1" == "backup-abort" ]; then
    DURATION=$((`date +%s`-`sed '1q;d' /tmp/backup-info`))
    /usr/bin/curl -s -i -XPOST -u $DBUSER:$DBPASS "http://$DBHOST:$DBPORT/write?db=$DBNAME" --data-binary  "backup_px,host=$HOSTNAME,location=$LOCATIONCODE success=0,duration=$DURATION,size=0" > /dev/null
    rm /tmp/backup-info
fi
