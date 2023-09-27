#!/bin/bash
#Just a simple script to write some stats to InfluxDB about your backup. Based on vzdump hook method.
TOKEN=<TOKEN>
ORGANIZATION=<ORGANIZATION>
LOCATIONCODE=<LOCATIONCODE>
PROTOCOL=<PROTOCOL> #HTTP or HTTPS
DBHOSTNAME=<DBHOSTNAME>
PORT=<PORT>
BUCKETNAME=<BUCKETNAME>
DEBUG=false #Debug mode, copy all logs to /tmp/timestamp
SPEED=""

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
        /usr/bin/curl --request POST "$PROTOCOL://$DBHOSTNAME:$PORT/api/v2/write?org=$ORGANIZATION&bucket=$BUCKETNAME&precision=ns" --data-binary  "proxmox,host=$HOSTNAME,location=$LOCATIONCODE success=0,duration=$DURATION,speed=0,size=0" --header "Authorization: Token $TOKEN" --header "Content-Type: text/plain; charset=utf-8" --header "Accept: application/json"
        rm /tmp/backup-info
    else
        if [ -f "${TARGET}" ]; then
            SPEED=`cat ${LOGFILE} | grep -o -P "(?<=seconds \().*(?= MB\/s| MiB\/s)"`
            if [ -z $SPEED ]; then
                SPEED=`cat ${LOGFILE} | grep -o -P "(?<=.iB, ).*(?=.iB\/s)"`
            fi
            DURATION=$((`cat ${LOGFILE} |grep -o -P "(?<=\()[0-9][0-9]:[0-9][0-9]:[0-9][0-9](?=\))"|awk -F':' '{print($1*3600)+($2*60)+$3}'`))
            /usr/bin/curl --request POST "$PROTOCOL://$DBHOSTNAME:$PORT/api/v2/write?org=$ORGANIZATION&bucket=$BUCKETNAME&precision=ns" --data-binary  "proxmox,host=$HOSTNAME,location=$LOCATIONCODE success=1,duration=$DURATION,speed=$SPEED,size=`stat -c%s $TARGET`" --header "Authorization: Token $TOKEN" --header "Content-Type: text/plain; charset=utf-8" --header "Accept: application/json"
        else
            SPEEDR=$((`cat ${LOGFILE} |grep -o -P "(?<=\().*(?=....\/s\))"`))
            SPEEDS=$((`cat ${LOGFILE} |grep -o -P "(?<=[0-9] ).(?=iB\/s\))"`))
            case $SPEEDS in
                K)
                    SPEED=`echo "$SPEEDR 1024" | awk '{printf "%f", $1 / $2}'`
                ;;
                M)
                    SPEED=$SPEEDR
                ;;
                G)
                    SPEED=`echo "$SPEEDR 1024" | awk '{printf "%f", $1 * $2}'`
                ;;
            esac
            DURATION=$((`cat ${LOGFILE} |grep -o -P "(?<=\()[0-9][0-9]:[0-9][0-9]:[0-9][0-9](?=\))"|awk -F':' '{print($1*3600)+($2*60)+$3}'`))
            SIZER=$((`cat ${LOGFILE} |grep -o -P "(?<=transferred ).*(?= [K|M|G]iB in )"`))
            SIZES=$((`cat ${LOGFILE} |grep -o -P "(?<=[0-9 ]).(?=iB in [0-9])"`))
            case $SIZES in
                K)
                    SIZE=`echo "$SIZER 1024" | awk '{printf "%f", $1 * $2}'`
                ;;
                M)
                    SIZE=`echo "$SIZER 1024" | awk '{printf "%f", $1 * $2 * $2}'`
                ;;
                G)
                    SIZE=`echo "$SIZER 1024" | awk '{printf "%f", $1 * $2 * $2 * $2}'`
                ;;
            esac
            /usr/bin/curl --request POST "$PROTOCOL://$DBHOSTNAME:$PORT/api/v2/write?org=$ORGANIZATION&bucket=$BUCKETNAME&precision=ns" --data-binary  "proxmox,host=$HOSTNAME,location=$LOCATIONCODE success=1,duration=$DURATION,speed=$SPEED,size=$SIZE" --header "Authorization: Token $TOKEN" --header "Content-Type: text/plain; charset=utf-8" --header "Accept: application/json"
        fi
    fi
fi
