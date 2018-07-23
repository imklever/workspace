#!/bin/bash

host_name="10.240.217.18"
username="LCTC08"
passwd="SYS201708"

disk_list="0 1 2 3 4 5 6 7 8 9 10 11"
for disk in $disk_list
do
    cmd="storage -config vol -remove -target vol[9-${disk}]"
    echo $cmd
    sshpass -p ${passwd} ssh ${username}@${host_name} -t ${cmd}
done

disk_list="0 1"
for disk in $disk_list
do
    cmd="storage -config vol -remove -target vol[1-${disk}]"
    echo $cmd
    sshpass -p ${passwd} ssh ${username}@${host_name} -t ${cmd}
done

