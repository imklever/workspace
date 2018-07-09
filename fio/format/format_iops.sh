#!/bin/bash

if [ $# -lt 1 ];then
    echo "usage: format.sh <logfile>"
    exit 1
fi

logfile=$1
cat $logfile | grep IOPS | awk -F "," '{print $1}' | awk -F "=" '{print $2}'
