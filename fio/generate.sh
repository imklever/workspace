#!/bin/bash

##########################
#generate <rw> <bs> <iodepth> <size ><filename> <>
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

    echo "[global]
ioengine=rbd
clientname=admin
pool=test_pool
rw=$rw
bs=$bs
#runtime=5
size=$size
iodepth=$iodepth
numjobs=5
direct=1
#rwmixread=70
group_reporting

[rbd_image0]
rbdname=test_image0
" > $filename
}






##########################
#main
##########################

_size="2M"

if [ -f run.sh -o -d ./config ];then
    echo "run.sh or config dir is already exist, do you want overwrite them?"
    while [ 1 ]
    do
        read var
        if [ $var"x" != "yesx" ];then
            echo "you chose no"
            exit 1
        fi
        break
    done
    rm -rf config run.sh
    mkdir config
fi


echo "#!/bin/bash
time_start=\"\$(date +%Y)-\$(date +%m)-\$(date +%d)_\$(date +%H)-\$(date +%M)-\$(date +%S)\"
timestamp_start=\"\$(date +%s)\"

echo \"time start:\"
echo \$time_start
echo \"\"

if [ ! -d ./log ];then
        mkdir ./log
fi

mkdir ./log/\${time_start}_${_size}
cp ./generate.sh ./run.sh ./log/\${time_start}_${_size}
cp -r ./config ./log/\${time_start}_${_size}

echo \"time start:\" > ./log/\${time_start}_${_size}/time.log
echo \"\${time_start}\" >> ./log/\${time_start}_${_size}/time.log
echo \"\${timestamp_start}\" >> ./log/\${time_start}_${_size}/time.log

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
        echo "time fio ./config/fio_${_rw}_${_bs}.config     >     ./log/\${time_start}_${_size}/fio_${_rw}_${_bs}.log" >> ./run.sh
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
        echo "time fio ./config/fio_${_rw}_${_bs}.config     >     ./log/\${time_start}_${_size}/fio_${_rw}_${_bs}.log" >> ./run.sh
        echo "echo \"\"" >> ./run.sh
        echo "">> ./run.sh
    done
done


echo "
time_stop=\"\$(date +%Y)-\$(date +%m)-\$(date +%d)_\$(date +%H)-\$(date +%M)-\$(date +%S)\"
timestamp_stop=\"\$(date +%s)\"

echo \"time stop:\"
echo \$time_stop

echo \"\" >> ./log/\${time_start}_${_size}/time.log
echo \"time stop:\" >> ./log/\${time_start}_${_size}/time.log
echo \"\${time_stop}\" >> ./log/\${time_start}_${_size}/time.log
echo \"\${timestamp_stop}\" >> ./log/\${time_start}_${_size}/time.log

echo \"\" >> ./log/\${time_start}_${_size}/time.log
echo \"time elapse:\" >> ./log/\${time_start}_${_size}/time.log

sec=\$(echo \"scale=4;\${timestamp_stop}-\${timestamp_start}\" | bc )
echo \"\${sec}(s)\" >> ./log/\${time_start}_${_size}/time.log

min=\$(echo \"scale=4;\${sec}/60\" | bc )
echo \"\${min}(m)\" >> ./log/\${time_start}_${_size}/time.log

hour=\$(echo \"scale=4;\${min}/60\" | bc )
echo \"\${hour}(h)\" >> ./log/\${time_start}_${_size}/time.log

echo \"\"
echo \"logdir:\"
echo \"./log/\${time_start}_${_size}\"
" >> run.sh

