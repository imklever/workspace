#!/bin/bash


#_log_base="/root/gitrepo/workspace/fio/fio_disk/disk_bare/log/log_37"
#_log_base="/root/gitrepo/workspace/fio/fio_disk/disk_bare/log/log_38"
#_log_base="/root/gitrepo/workspace/fio/fio_disk/disk_bare/log/log_39"
#_log_base="/root/gitrepo/workspace/fio/fio_disk/disk_xfs/log/log_37"
#_log_base="/root/gitrepo/workspace/fio/fio_disk/disk_xfs/log/log_38"
#_log_base="/root/gitrepo/workspace/fio/fio_disk/disk_xfs/log/log_39"
#_log_base="/root/gitrepo/workspace/fio/fio_disk/disk_bare/log/RAID0/log_37"
#_log_base="/root/gitrepo/workspace/fio/fio_disk/disk_bare/log/RAID0/log_38"
#_log_base="/root/gitrepo/workspace/fio/fio_disk/disk_bare/log/RAID0/log_39"
#_log_base="/root/gitrepo/workspace/fio/fio_disk/disk_xfs/log/RAID0/log_37"
#_log_base="/root/gitrepo/workspace/fio/fio_disk/disk_xfs/log/RAID0/log_38"
#_log_base="/root/gitrepo/workspace/fio/fio_disk/disk_xfs/log/RAID0/log_39"
_log_base="/root/gitrepo/workspace/fio/fio_ceph_randwrite_write_only/librbd"
_folder_list="ceph_log"

log_name="performance.log"
rm -rf $log_name



#####################################
#IOPS
#####################################
echo ""
echo "begin with IOPS:"

#_file_list="randwrite_04k randwrite_08k randwrite_64k randread_04k randread_08k randread_64k write_64k write_512k write_1m read_64k read_512k read_1m"
#_file_list="write_04k write_08k write_16k write_32k write_64k write_128k write_512k write_1m write_2m write_4m write_6m write_8m write_10m write_12m write_16m write_20m write_24m write_28m write_32m write_64m write_128m"
_file_list="randwrite_04k randwrite_08k randwrite_16k randwrite_32k randwrite_64k randwrite_128k randwrite_512k randwrite_1m randwrite_2m randwrite_4m randwrite_6m randwrite_8m randwrite_10m randwrite_12m randwrite_16m randwrite_20m randwrite_24m randwrite_28m randwrite_32m randwrite_64m randwrite_128m"

ssd_number="2"
performance_name="IOPS"
series_name="$_file_list"
x_axis="disk name"
y_axis="IOPS"

echo "IOPS" >> $log_name
echo $ssd_number        >> $log_name
echo $performance_name  >> $log_name
echo $series_name       >> $log_name
echo $x_axis            >> $log_name
echo $y_axis            >> $log_name
echo $_folder_list      >> $log_name


for file in $_file_list
do
    echo "$file"

    result=""
    for folder in $_folder_list
    do
        log_file="$_log_base/$folder/fio_${file}.log"
        value=""
        value=`./get_IOPS.sh $log_file`
        value=`./unit_format_IOPS.py $value`
        result="$result $value"
    done
    echo $result    >> $log_name
done
echo "done with IOPS"


#####################################
#BW
#####################################
echo ""
echo "begin with BW:"

#_file_list="randwrite_04k randwrite_08k randwrite_64k randread_04k randread_08k randread_64k write_64k write_512k write_1m read_64k read_512k read_1m"
#_file_list="write_04k write_08k write_16k write_32k write_64k write_128k write_512k write_1m write_2m write_4m write_6m write_8m write_10m write_12m write_16m write_20m write_24m write_28m write_32m write_64m write_128m"
_file_list="randwrite_04k randwrite_08k randwrite_16k randwrite_32k randwrite_64k randwrite_128k randwrite_512k randwrite_1m randwrite_2m randwrite_4m randwrite_6m randwrite_8m randwrite_10m randwrite_12m randwrite_16m randwrite_20m randwrite_24m randwrite_28m randwrite_32m randwrite_64m randwrite_128m"

ssd_number="2"
performance_name="BW"
series_name="$_file_list"
x_axis="disk name"
y_axis="MiB/s"

echo "BW"               >> $log_name
echo $ssd_number        >> $log_name
echo $performance_name  >> $log_name
echo $series_name       >> $log_name
echo $x_axis            >> $log_name
echo $y_axis            >> $log_name
echo $_folder_list      >> $log_name


for file in $_file_list
do
    echo "$file"

    result=""
    for folder in $_folder_list
    do
        log_file="$_log_base/$folder/fio_${file}.log"
        value=""
        value=`./get_BW.sh $log_file`
        value=`./unit_format_BW.py $value`
        result="$result $value"
    done
    echo $result    >> $log_name
done
echo "done with BW"

#####################################
#生成exce图表
#####################################
echo ""
echo "begin create execl:"

./scripts/xlsx.py $log_name

./scripts/sz.sh
