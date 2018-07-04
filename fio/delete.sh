#!/bin/bash



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
        rm -f ./config/$_file_name
    done
done




_bs_list="04k 08k 64k"
_rw_list="randread randwrite"
for _bs in $_bs_list
do
    for _rw in $_rw_list
    do
        _file_name="fio_${_rw}_${_bs}.config"
        rm -f ./config/$_file_name
    done
done

