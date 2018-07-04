#!/bin/bash

##########################
#generate <rw> <bs> <iodepth> <> <>
##########################
function generate()
{
    if [ $# -lt 4 ];then
        echo 1
        return 1
    fi
    rw=$1
    bs=$2
    iodepth=$3
    filename=$4
    echo "[global]
ioengine=rbd
clientname=admin
pool=test_pool
rw=$rw
bs=$bs
#runtime=5
size=10M
iodepth=$iodepth
numjobs=5
direct=1
#rwmixread=70
group_reporting

[rbd_image0]
rbdname=test_image0

[rbd_image1]
rbdname=test_image1
" > $filename
}






##########################
#main
##########################
_bs_list="64k 512k 1m"
_rw_list="read write"
for _bs in $_bs_list
do
    for _rw in $_rw_list
    do
        _file_name="fio_${_rw}_${_bs}.config"
        touch $_file_name
        generate $_rw $_bs 64 $_file_name
    done
done


_bs_list="04k 08k 64k"
_rw_list="randread randwrite"
for _bs in $_bs_list
do
    for _rw in $_rw_list
    do
        _file_name="fio_${_rw}_${_bs}.config"
        touch $_file_name
        generate $_rw $_bs 64 $_file_name
    done
done
