#!/bin/bash


_log_base="/root/gitrepo/workspace/fio/log_39"
#_log_base="/root/workspace/gitrepo/workspace/fio/log_39"
_folder_list="sda sdb sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn"
_file_list="fio_randwrite_04k.log"


log_name="performance.log"
rm -rf $log_name



#####################################
#IOPS
#####################################
result=""
for file in $_file_list
do
    for folder in $_folder_list
    do
        log_file="$_log_base/$folder/$file"
        value=""
        value=`./get_IOPS.sh $log_file`
        value=`./unit_format_IOPS.py $value`
        result="$result $value"
    done
done

ssd_number="2"
performance_name="IOPS"
x_axis="disk name"
y_axis="IOPS"

echo "IOPS" >> $log_name
echo $ssd_number >> $log_name
echo $performance_name >> $log_name
echo $x_axis >> $log_name
echo $y_axis >> $log_name
echo $_folder_list >> $log_name
echo $result >> $log_name

./xlsx.py $log_name

#####################################
#IOPS
#####################################
result=""
for file in $_file_list
do
    for folder in $_folder_list
    do
        log_file="$_log_base/$folder/$file"
        value=""
        value=`./get_BW.sh $log_file`
        value=`./unit_format_BW.py $value`
        result="$result $value"
    done
done

ssd_number="2"
performance_name="BW"
x_axis="disk name"
y_axis="MiB/s"

echo "BW" >> $log_name
echo $ssd_number >> $log_name
echo $performance_name >> $log_name
echo $x_axis >> $log_name
echo $y_axis >> $log_name
echo $_folder_list >> $log_name
echo $result >> $log_name


./xlsx.py $log_name

./sz.sh
