#!/bin/bash


_log_base="/root/gitrepo/workspace/fio/fio_disk/disk_bare/log/log_37"
_folder_list="sda sdb sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn"

log_name="performance.log"
rm -rf $log_name



#####################################
#IOPS
#####################################
result1=""
result2=""
result3=""
for folder in $_folder_list
do
    log_file="$_log_base/$folder/fio_randwrite_04k.log"
    value=""
    value=`./get_IOPS.sh $log_file`
    value=`./unit_format_IOPS.py $value`
    result1="$result1 $value"
    log_file="$_log_base/$folder/fio_randwrite_08k.log"
    value=""
    value=`./get_IOPS.sh $log_file`
    value=`./unit_format_IOPS.py $value`
    result2="$result2 $value"
    log_file="$_log_base/$folder/fio_randwrite_64k.log"
    value=""
    value=`./get_IOPS.sh $log_file`
    value=`./unit_format_IOPS.py $value`
    result3="$result3 $value"
done

ssd_number="2"
performance_name="IOPS"
series_name="randwrite_04k randwrite_08k randwrite_64k"
x_axis="disk name"
y_axis="IOPS"

echo "IOPS" >> $log_name
echo $ssd_number        >> $log_name
echo $performance_name  >> $log_name
echo $series_name       >> $log_name
echo $x_axis            >> $log_name
echo $y_axis            >> $log_name
echo $_folder_list      >> $log_name
echo $result1           >> $log_name
echo $result2           >> $log_name
echo $result3           >> $log_name


#####################################
#IOPS
#####################################
result1=""
result2=""
result3=""
for folder in $_folder_list
do
    log_file="$_log_base/$folder/fio_randwrite_04k.log"
    value=""
    value=`./get_BW.sh $log_file`
    value=`./unit_format_BW.py $value`
    result1="$result1 $value"
    log_file="$_log_base/$folder/fio_randwrite_08k.log"
    value=""
    value=`./get_BW.sh $log_file`
    value=`./unit_format_BW.py $value`
    result2="$result2 $value"
    log_file="$_log_base/$folder/fio_randwrite_64k.log"
    value=""
    value=`./get_BW.sh $log_file`
    value=`./unit_format_BW.py $value`
    result3="$result3 $value"
done

ssd_number="2"
performance_name="BW"
series_name="randwrite_04k randwrite_08k randwrite_64k"
x_axis="disk name"
y_axis="MiB/s"

echo "BW"               >> $log_name
echo $ssd_number        >> $log_name
echo $performance_name  >> $log_name
echo $series_name       >> $log_name
echo $x_axis            >> $log_name
echo $y_axis            >> $log_name
echo $_folder_list      >> $log_name
echo $result1            >> $log_name
echo $result2           >> $log_name
echo $result3           >> $log_name


./xlsx.py $log_name

./sz.sh
