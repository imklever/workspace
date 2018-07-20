#!/bin/bash

host_name="10.240.217.17"
username="LCTC07"
passwd="SYS201707"

disk_list="0 1 2 3 4 5 6 7 8 9 10 11"
for disk in $disk_list
do
    cmd="storage -config vol -remove -target vol[9-${disk}]"
    echo $cmd
    sshpass -p ${passwd} ssh ${username}@10.240.217.17 -t ${cmd}
done

disk_list="12 13"
for disk in $disk_list
do
    cmd="storage -config vol -remove -target vol[1-${disk}]"
    echo $cmd
    sshpass -p ${passwd} ssh ${username}@10.240.217.17 -t ${cmd}
done

