#!/bin/bash


#_log_base="/root/gitrepo/workspace/fio/log_39"
_log_base="/root/workspace/gitrepo/workspace/fio/log_39"
_folder_list="sda sdb sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn"
_file_list="fio_randwrite_04k.log"


result=""
for file in $_file_list
do
    for folder in $_folder_list
    do
        log_file="$_log_base/$folder/$file"
        value=""
        value=`./get_iops.sh $log_file`
        value=`./unit_format.py $value`
        result="$result $value"
    done
done

echo $_folder_list > iops.log
echo $result >> iops.log

./xlsx.py iops.log

