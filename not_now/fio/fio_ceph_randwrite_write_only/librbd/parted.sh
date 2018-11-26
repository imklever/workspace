#!/bin/bash

disk_list="a b d e f g h i j k l m n"
for i in $disk_list
do
    echo ${i}
    parted /dev/sd${i} -s "mklabel msdos"
    parted /dev/sd${i} -s "mklabel gpt"
    parted /dev/sd${i} -s "mkpart primary 0 -1"
    time mkfs.xfs -f /dev/sd${i}1
done
