#!/bin/bash

flag="disk"
#flag="ceph"

##########################
#generate <rw> <bs> <iodepth> <size > <filename>
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
    size=$4
    filename=$5
    
    if [ "disk" == $flag ];then
    echo "[global]
ioengine=libaio
rw=$rw
bs=$bs
#runtime=5
size=$size
numjobs=1
iodepth=$iodepth
direct=1
#rwmixread=70
group_reporting

[test]
filename=/dev/sdb
" > $filename
    fi

    if [ "ceph" == $flag ];then
    echo "[global]
ioengine=rbd
clientname=admin
pool=test_pool
rw=$rw
bs=$bs
#runtime=5
size=$size
numjobs=1
iodepth=$iodepth
direct=1
#rwmixread=70
group_reporting

[rbd_image0]
rbdname=test_image0
" > $filename
    fi

}






##########################
#main
##########################

_size="1G"

#if [ -f run.sh -o -d ./config ];then
#    echo "run.sh or config dir is already exist, do you want overwrite them?[yes/no]"
#    while [ 1 ]
#    do
#        read var
#        if [ $var"x" != "yesx" ];then
#            echo "you chose no"
#            exit 1
#        fi
#        break
#    done
#    rm -rf config run.sh
#    mkdir config
#fi


echo "#!/bin/bash
time_start=\"\$(date +%Y)-\$(date +%m)-\$(date +%d)_\$(date +%H)-\$(date +%M)-\$(date +%S)\"
timestamp_start=\"\$(date +%s)\"

echo \"time start:\"
echo \$time_start
echo \"\"

if [ ! -d ./log ];then
        mkdir ./log
fi

log_dir=\"./log/\${time_start}_${_size}\"

mkdir \${log_dir}

cp ./generate.sh ./run.sh \${log_dir}
cp -r ./config \${log_dir}

echo \"time start:\" > \${log_dir}/time.log
echo \"\${time_start}\" >> \${log_dir}/time.log
echo \"\${timestamp_start}\" >> \${log_dir}/time.log

" > run.sh




_bs_list="64k 512k 1m"
_rw_list="write read "
for _bs in $_bs_list
do
    for _rw in $_rw_list
    do
        _file_name="./config/fio_${_rw}_${_bs}.config"
        touch $_file_name
        generate $_rw $_bs 64 $_size $_file_name
        echo "echo \"./config/fio_${_rw}_${_bs}.config\"" >> ./run.sh
        echo "time fio ./config/fio_${_rw}_${_bs}.config     >     \${log_dir}/fio_${_rw}_${_bs}.log" >> ./run.sh
        echo "echo \"\"" >> ./run.sh
        echo "">> ./run.sh
    done
done




_bs_list="04k 08k 64k"
_rw_list="randwrite randread"
for _bs in $_bs_list
do
    for _rw in $_rw_list
    do
        _file_name="./config/fio_${_rw}_${_bs}.config"
        touch $_file_name
        generate $_rw $_bs 64 $_size $_file_name
        echo "echo \"./config/fio_${_rw}_${_bs}.config\"" >> ./run.sh
        echo "time fio ./config/fio_${_rw}_${_bs}.config     >     \${log_dir}/fio_${_rw}_${_bs}.log" >> ./run.sh
        echo "echo \"\"" >> ./run.sh
        echo "">> ./run.sh
    done
done


echo "
time_stop=\"\$(date +%Y)-\$(date +%m)-\$(date +%d)_\$(date +%H)-\$(date +%M)-\$(date +%S)\"
timestamp_stop=\"\$(date +%s)\"

echo \"time stop:\"
echo \$time_stop

echo \"\" >> \${log_dir}/time.log
echo \"time stop:\" >> \${log_dir}/time.log
echo \"\${time_stop}\" >> \${log_dir}/time.log
echo \"\${timestamp_stop}\" >> \${log_dir}/time.log

echo \"\" >> \${log_dir}/time.log
echo \"time elapse:\" >> \${log_dir}/time.log

sec=\$(echo \"scale=4;\${timestamp_stop}-\${timestamp_start}\" | bc )
echo \"\${sec}(s)\" >> \${log_dir}/time.log

min=\$(echo \"scale=4;\${sec}/60\" | bc )
echo \"\${min}(m)\" >> \${log_dir}/time.log

hour=\$(echo \"scale=4;\${min}/60\" | bc )
echo \"\${hour}(h)\" >> \${log_dir}/time.log

echo \"\"
echo \"logdir:\"
echo \"\${log_dir}\"
" >> run.sh

chmod +x run.sh
