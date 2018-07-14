#!/bin/bash


##########################
#configuration
##########################
_size="1M"
_disk_list="sda sdb sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn"

_rw_list="write read "
_rw_bs_list="64k 512k 1m"

_rand_rw_list="randwrite randread"
_rand_rw_bs_list="04k 08k 64k"








##########################
#generate <disk> <rw> <bs> <iodepth> <size > <filename>
##########################
function generate()
{
    if [ $# -lt 6 ];then
        echo "wrong parameters!
        usage: generate <disk> <rw> <bs> <iodepth> <size > <filename>"
        exit 1
    fi
    disk=$1
    rw=$2
    bs=$3
    iodepth=$4
    size=$5
    filename=$6
    
    echo "[global]
ioengine=libaio
rw=$rw
bs=$bs
#runtime=5
size=$size
iodepth=$iodepth
numjobs=1
direct=1
#rwmixread=70
group_reporting

[test]
filename=${disk}/fio_test_file
" > $filename

}



##########################
#time start
##########################
function time_start()
{
    echo "#!/bin/bash

    trap '{ echo \"Ctrl-C to quit.\" ; exit 1; }' INT

    _disk_list=\"$_disk_list\"
    " > run.sh

    echo "
    lsblk
    echo \"\"

    df -Th
    echo \"\"

    echo -e \"these disk will be \\033[31mformatted\\033[0m, do you want to continue?\"
    echo -e \"make sure the \\033[31mOS disk\\033[0m is not one of them!\"
    echo -e \"\\033[47;31m\"
    for i in \$_disk_list
    do
        echo \${i}
    done
    echo -e \"\\033[0m\"
    echo -e \"\\033[31;5m[yes/no]?\\033[0m\"
    while [ 1 ]
    do
        read var
        if [ \$var\"x\" != \"yesx\" ];then
            echo \"you chose no\"
            exit 1
        else
            break
        fi
    done

    echo \"\"
    echo \"formatting disk...\"
    for i in \${_disk_list}
    do
        echo \${i}
        parted /dev/\${i} -s \"mklabel msdos\"
        parted /dev/\${i} -s \"mklabel gpt\"
    done

    echo \"\"
    lsblk

    sleep 5

    echo \"\"
    echo \"formatting disk into one primary partition\"
    for i in \${_disk_list}
    do
        echo \${i}
        parted /dev/\${i} -s \"mkpart primary 0 -1\"
    done

    echo \"\"
    lsblk

    sleep 5

    echo \"\"
    echo \"formatting disk with xfs...\"
    for i in \${_disk_list}
    do
        echo \${i}
        mkfs.xfs -f /dev/\${i}1
        if [ -d /mnt/\${i} ];then
            rm -rf /mnt/\${i}
        fi
        mkdir /mnt/\${i}
        mount /dev/\${i}1 /mnt/\${i}
    done

    echo \"\"
    lsblk

    echo \"\"
    df -Th

    echo -e \"\\033[47;31m\"
    echo -e \"make sure the mount is right\"
    echo -e \"\\033[0m\"
    echo -e \"\\033[31;5m[yes/no]?\\033[0m\"
    while [ 1 ]
    do
        read var
        if [ \$var\"x\" != \"yesx\" ];then
            echo \"you chose no\"
            exit 1
        else
            break
        fi
    done



    time_start=\"\$(date +%Y)-\$(date +%m)-\$(date +%d)_\$(date +%H)-\$(date +%M)-\$(date +%S)\"
    timestamp_start=\"\$(date +%s)\"

    echo \"\"
    echo \"time start:\"
    echo \$time_start
    echo \"\"
    echo \"\"
    echo \"\"
    echo \"\"

    #create log folder
    if [ -d ./log ];then
        mv ./log bak.\${time_start}
    fi
    mkdir ./log

    for i in \${_disk_list}
    do
        mkdir ./log/\${i}
    done

    #bakup config file
    cp ./generate.sh ./run.sh ./log
    cp -r ./config ./log

    echo \"time start:\" > ./log/time.log
    echo \"\${time_start}\" >> ./log/time.log
    echo \"\${timestamp_start}\" >> ./log/time.log

    " >> run.sh
}


##########################
#time start on disk test
##########################
function time_start_on_disk()
{
    echo "

    time_start_disk=\"\$(date +%Y)-\$(date +%m)-\$(date +%d)_\$(date +%H)-\$(date +%M)-\$(date +%S)\"
    timestamp_start_disk=\"\$(date +%s)\"

    echo \"test on ${_disk} time start:\"
    echo \$time_start_disk
    echo \"\"

    echo \"time start:\" > ./log/${_disk}/time.log
    echo \"\${time_start_disk}\" >> ./log/${_disk}/time.log
    echo \"\${timestamp_start_disk}\" >> ./log/${_disk}/time.log

    " >> run.sh


}



##########################
#time stop on disk test
##########################
function time_stop_on_disk()
{
    echo "

    time_stop_disk=\"\$(date +%Y)-\$(date +%m)-\$(date +%d)_\$(date +%H)-\$(date +%M)-\$(date +%S)\"
    timestamp_stop_disk=\"\$(date +%s)\"

    echo \"\"
    echo \"test on ${_disk} time stop:\"
    echo \$time_stop_disk
    echo \"\"

    echo \"test on ${_disk} time stop:\" > ./log/${_disk}/time.log
    echo \"\${time_stop_disk}\" >> ./log/${_disk}/time.log
    echo \"\${timestamp_stop_disk}\" >> ./log/${_disk}/time.log
    echo \"\" >> ./log/${_disk}/time.log

    sec=\$(echo \"scale=4;\${timestamp_stop_disk}-\${timestamp_start_disk}\" | bc )
    min=\$(echo \"scale=4;\${sec}/60\" | bc )
    hour=\$(echo \"scale=4;\${min}/60\" | bc )

    echo \"time elapse:\"
    echo \"\${sec}(s)\"
    echo \"\${min}(m)\"
    echo \"\${hour}(h)\"

    echo \"time elapse:\" >> ./log/${_disk}/time.log
    echo \"\${sec}(s)\" >> ./log/${_disk}/time.log
    echo \"\${min}(m)\" >> ./log/${_disk}/time.log
    echo \"\${hour}(h)\" >> ./log/${_disk}/time.log

    " >> run.sh

}



##########################
#time stop
##########################
function time_stop()
{
    echo "
    echo \"\"
    echo \"\"
    echo \"\"
    echo \"\"
    time_stop=\"\$(date +%Y)-\$(date +%m)-\$(date +%d)_\$(date +%H)-\$(date +%M)-\$(date +%S)\"
    timestamp_stop=\"\$(date +%s)\"

    echo \"\" >> ./log/time.log
    echo \"time stop:\" >> ./log/time.log
    echo \"\${time_stop}\" >> ./log/time.log
    echo \"\${timestamp_stop}\" >> ./log/time.log
    echo \"\" >> ./log/time.log

    sec=\$(echo \"scale=4;\${timestamp_stop}-\${timestamp_start}\" | bc )
    min=\$(echo \"scale=4;\${sec}/60\" | bc )
    hour=\$(echo \"scale=4;\${min}/60\" | bc )

    echo \"time elapse:\" >> ./log/time.log
    echo \"\${sec}(s)\" >> ./log/time.log
    echo \"\${min}(m)\" >> ./log/time.log
    echo \"\${hour}(h)\" >> ./log/time.log

    echo \"\"
    echo \"logdir:\"
    echo \"./log\"

    echo \"\"
    echo \"time start:\"
    echo \$time_start
    echo \"\"
    echo \"time stop:\"
    echo \$time_stop

    echo \"\"
    echo \"time elapse:\"
    echo \"\${sec}(s)\"
    echo \"\${min}(m)\"
    echo \"\${hour}(h)\"

    for i in \${_disk_list}
    do
        echo \${i}
        umount /mnt/\${i}
        rm -rf /mnt/\${i}
    done

    " >> run.sh
}



##########################
#main
##########################

time_start="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H)-$(date +%M)-$(date +%S)"
if [ -d ./config ];then
    mv ./config ./bak.config.${time_start}
    
fi
mkdir ./config

for i in ${_disk_list}
do
    mkdir ./config/${i}
done


time_start


for _disk in $_disk_list
do
    time_start_on_disk
    for _bs in $_rw_bs_list
    do
        for _rw in $_rw_list
        do
            _config_file="./config/${_disk}/fio_${_rw}_${_bs}.config"
            _log_file="./log/${_disk}/fio_${_rw}_${_bs}.log"
            touch $_config_file
            generate "/mnt/${_disk}" $_rw $_bs 64 $_size $_config_file
            echo "    echo \"${_config_file}\"" >> ./run.sh
            echo "    /usr/bin/time -f \"time:%E\\nuser:%U\\nsys:%S\" -o ${_log_file}.time fio ${_config_file}  >  ${_log_file}" >> ./run.sh
        done
    done

    for _bs in $_rand_rw_bs_list
    do
        for _rw in $_rand_rw_list
        do
            _config_file="./config/${_disk}/fio_${_rw}_${_bs}.config"
            _log_file="./log/${_disk}/fio_${_rw}_${_bs}.log"
            touch $_config_file
            generate "/mnt/${_disk}" $_rw $_bs 64 $_size $_config_file
            echo "    echo \"${_config_file}\"" >> ./run.sh
            echo "    /usr/bin/time -f \"time:%E\\nuser:%U\\nsys:%S\" -o ${_log_file}.time fio ${_config_file}  >  ${_log_file}" >> ./run.sh
        done
    done
    time_stop_on_disk
    echo "    echo \"\"" >> ./run.sh
    echo "    echo \"\"" >> ./run.sh
    echo "    echo \"\"" >> ./run.sh
    echo "    echo \"\"" >> ./run.sh
    echo "" >> ./run.sh
done

time_stop

chmod +x run.sh
