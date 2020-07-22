#!/bin/bash
#Just a simple script to wtite some stats to InfluxDB about your backup. Based on vzdump hook method.
DBUSER=<DBUSER>
DBPASS=<DBPASS>
DBPROTO=<DBPROTO> #HTTP or HTTPS
DBHOST=<DBHOST>
DBPORT=<DBPORT>
DBNAME=<DBNAME>
LOCATIONCODE=<LOCATION_CODE>
DEBUG=false #Debug mode, copy all logs to /tmp/timestamp

if [ "$1" == "backup-start" ]; then
    echo `date +%s` > /tmp/backup-info
    echo $HOSTNAME >> /tmp/backup-info
fi

if [ "$1" == "log-end" ]; then
    if [ "$DEBUG" = true ]; then
        cp ${LOGFILE} /tmp/`date +%s`
    fi
    if [ `cat ${LOGFILE} | grep ERROR | wc -l` -gt 0 ]; then
        DURATION=$((`date +%s`-`sed '1q;d' /tmp/backup-info`))
        /usr/bin/curl -s -i -XPOST -u $DBUSER:$DBPASS "$DBPROTO://$DBHOST:$DBPORT/write?db=$DBNAME" --data-binary  "proxmox,host=$HOSTNAME,location=$LOCATIONCODE success=0,duration=$DURATION,speed=0,size=0" > /tmp/tst
        rm /tmp/backup-info
    else
        SPEED=$((`cat ${LOGFILE} | grep -o -P "(?<=seconds \().*(?= MB\/s| MiB\/s)"`))
        if [ ! "$SPEED" -gt 0 ]; then
            SPEED=$(cat ${LOGFILE} | grep -o -P "(?<=.iB, ).*(?=.iB\/s)")
        fi
        DURATION=$((`cat ${LOGFILE} |grep -o -P "(?<=\()[0-9][0-9]:[0-9][0-9]:[0-9][0-9](?=\))"|awk -F':' '{print($1*3600)+($2*60)+$3}'`))
        /usr/bin/curl -s -i -XPOST -u $DBUSER:$DBPASS "$DBPROTO://$DBHOST:$DBPORT/write?db=$DBNAME" --data-binary  "proxmox,host=$HOSTNAME,location=$LOCATIONCODE success=1,duration=$DURATION,speed=$SPEED,size=`stat -c%s $TARFILE`" > /tmp/tst
        echo $TRAFILE >> /tmp/tst
    fi
fi
