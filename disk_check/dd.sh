#!/bin/bash

sectors=524285952
step=1000000

#write data
for i in `seq 0 ${step} ${sectors}`
do
    str=`printf "%010d\n" "$i"`

    echo $str | dd of=/dev/sdb seek=${i} bs=10 count=1
    
    rate=`echo "scale=4;ans=$i/$sectors*100;ans;" | bc`%

    echo "write: ${i}/${sectors} ${rate}"
done

#read & compare data
for i in `seq 0 ${step} ${sectors}`
do
    str=`printf "%010d\n" "$i"`

    readstr=`dd if=/dev/sdb skip=${i} bs=10 count=1`

    rate=`echo "scale=4;$i/$sectors*100" | bc`%

    echo "read: ${i}/${sectors} $rate $readstr"
    if [ $readstr != $str ];then
        echo "wrong!"
        echo "supposed: $str"
        echo "read    : $readstr"
        exit
    fi
done
