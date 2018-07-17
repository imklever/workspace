#!/bin/bash

if [ $# -lt 1 ];then
    echo "usage: format.sh <logfile>"
    exit 1
fi

logfile=$1
result=`cat $logfile | grep BW | awk -F "," '{print $2}' | awk '{print $1}' | awk -F "=" '{print $2}'`
echo $result
