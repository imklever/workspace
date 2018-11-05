#!/bin/bash

echo "hello" > ./inputfile
#sectors=421773312
#dd if=./inputfile of=/dev/sdb1 seek=${sectors} bs=5 count=1
#dd if=/dev/sdb1 of=./outputfile skip=${sectors} bs=5 count=1
#echo >> ./outputfile
#cat ./outputfile
#diff ./inputfile ./outputfile
#rm -f ./inputfile ./outputfile

sectors=421773312
#sectors=10000
step=10000
for i in `seq 0 ${step} ${sectors}`
do
    str=`printf "%010d\n" "$i"`
    echo $str > ./inputfile
    dd if=./inputfile of=/dev/sdb1 seek=${i} bs=10 count=1
    rate=`echo "scale=4;$i/$sectors*100" | bc`
    echo "write: ${i}/${sectors} $rate"
done

for i in `seq 0 ${step} ${sectors}`
do
    dd if=/dev/sdb1 of=./outputfile skip=${i} bs=10 count=1
    str=`printf "%010d\n" "$i"`
    readstr=`cat ./outputfile`

    rate=`echo "scale=4;$i/$sectors*100" | bc`
    echo "read: ${i}/${sectors} $rate"
    #echo $readstr
    if [ $readstr != $str ];then
        echo "wrong!"
        echo "supposed: $str"
        echo "read    : $readstr"
        exit
    fi
done
