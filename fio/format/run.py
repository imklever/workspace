#!/bin/env python

import commands


_log_base="/root/gitrepo/workspace/fio/log_39"
_folder_list="sda sdb sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn"
_file_list="fio_randwrite_04k.log"


#function trans_number()
#{
#    if [ -z "$1" ];then
#        echo "function \"trans_number()\" must have atleast one parameter."
#        exit 1
#    fi
#
#    unit_flag=""
#
#    number=$1
#
#    number=`echo $number | sed 's/^[ ]*//g' | sed 's/[ ]*$//g'`
#
#    unit_flag=`echo ${number:0-1}`
#
#    echo $unit_flag
#
#    if [ "$unit_flag" == k -o "$unit_flag" == K ];then
#
#    fi
#
#}
#
#
#
#
#result=""
#for file in $_file_list
#do
#    for folder in $_folder_list
#    do
#        log_file="$_log_base/$folder/$file"
#        value=""
#        value=`./format_iops.sh $log_file`
#        echo $value
#        value=trans_number $value
#        result="$result $value"
#    done
#done


for file in _file_list:
    for folder in _folder_list:
        log_file=""
        log_file= _log_base+"/"+folder+"/"+file
        value=""
        cmd="./format_iops.sh "+log_file
        (status, value) = commands.getstatusoutput(cmd)
        print type(value)
        print value
