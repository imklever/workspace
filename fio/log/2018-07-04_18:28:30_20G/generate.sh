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

_size="20G"



echo "#!/bin/bash
time_record=\"\$(date +%Y)-\$(date +%m)-\$(date +%d)_\$(date +%H):\$(date +%M):\$(date +%S)\"

echo \$time_record
echo \"\"

if [ ! -d ./log ];then
        mkdir ./log
    fi

    mkdir ./log/\${time_record}_${_size}
    cp ./generate.sh ./run.sh ./log/\${time_record}_${_size}

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
        echo "time fio ./config/fio_${_rw}_${_bs}.config     >     ./log/\${time_record}_${_size}/fio_${_rw}_${_bs}.log" >> ./run.sh
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
        echo "time fio ./config/fio_${_rw}_${_bs}.config     >     ./log/\${time_record}_${_size}/fio_${_rw}_${_bs}.log" >> ./run.sh
        echo "echo \"\"" >> ./run.sh
        echo "">> ./run.sh
    done
done



