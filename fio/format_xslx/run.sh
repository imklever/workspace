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
_log_base="/root/gitrepo/workspace/fio/fio_disk/disk_xfs/log/RAID0/log_39"
_folder_list="sda sdb sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn"

log_name="performance.log"
rm -rf $log_name



#####################################
#IOPS
#####################################
echo ""
echo "begin with IOPS:"

_file_list="randwrite_04k randwrite_08k randwrite_64k randread_04k randread_08k randread_64k write_64k write_512k write_1m read_64k read_512k read_1m"

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

_file_list="randwrite_04k randwrite_08k randwrite_64k randread_04k randread_08k randread_64k write_64k write_512k write_1m read_64k read_512k read_1m"

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
