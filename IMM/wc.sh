#!/bin/bash

host_name="10.240.217.17"
username="LCTC07"
passwd="SYS201707"

disk_list="0 1 2 3 4 5 6 7 8 9 10 11"
for disk in disk_list
do
    cnt=`sshpass -p ${passwd} ssh -t ${username}@10.240.217.17 "storage -list volumes" | wc -l`
    echo "cnt: $cnt"
    
    
done

