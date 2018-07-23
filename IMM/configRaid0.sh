#!/bin/bash

host_name="10.240.217.18"
username="LCTC08"
passwd="SYS201708"

cnt=0
cnt_tmp=0
disk_list="0 1 2 3 4 5 6 7 8 9 10 11"
for disk in $disk_list
do
    cmd="storage -config vol -add -R 0 -D disk[9-${disk}] -N leo_raid0 -f 1 -target ctrl[9]"
    echo $cmd
    sshpass -p ${passwd} ssh ${username}@${host_name} -t ${cmd}
    while [ 1 ]
    do
        cnt=`sshpass -p ${passwd} ssh -t ${username}@${host_name} "storage -list volumes" | wc -l`
        if [ $cnt -gt $cnt_tmp ];then
            cnt_tmp=$cnt
            echo "cnt: $cnt"
            break
        fi
    done
done

disk_list="12 13"
for disk in $disk_list
do
    cmd="storage -config vol -add -R 0 -D disk[1-${disk}] -N leo_raid0 -f 1 -target ctrl[1]"
    echo $cmd
    sshpass -p ${passwd} ssh ${username}@${host_name} -t ${cmd}
    while [ 1 ]
    do
        cnt=`sshpass -p ${passwd} ssh -t ${username}@${host_name} "storage -list volumes" | wc -l`
        if [ $cnt -gt $cnt_tmp ];then
            cnt_tmp=$cnt
            echo "cnt: $cnt"
            break
        fi
    done
done

