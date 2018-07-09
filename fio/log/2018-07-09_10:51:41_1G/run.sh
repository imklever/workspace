#!/bin/bash
time_start="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H):$(date +%M):$(date +%S)"
timestamp_start="$(date +%s)"

echo "time start:"
echo $time_start
echo ""

if [ ! -d ./log ];then
        mkdir ./log
fi

mkdir ./log/${time_start}_1G
cp ./generate.sh ./run.sh ./log/${time_start}_1G

echo "time start:" > ./log/${time_start}_1G/time.log
echo "${time_start}" >> ./log/${time_start}_1G/time.log
echo "${timestamp_start}" >> ./log/${time_start}_1G/time.log


echo "./config/fio_write_64k.config"
time fio ./config/fio_write_64k.config     >     ./log/${time_start}_1G/fio_write_64k.log
echo ""

echo "./config/fio_read_64k.config"
time fio ./config/fio_read_64k.config     >     ./log/${time_start}_1G/fio_read_64k.log
echo ""

echo "./config/fio_write_512k.config"
time fio ./config/fio_write_512k.config     >     ./log/${time_start}_1G/fio_write_512k.log
echo ""

echo "./config/fio_read_512k.config"
time fio ./config/fio_read_512k.config     >     ./log/${time_start}_1G/fio_read_512k.log
echo ""

echo "./config/fio_write_1m.config"
time fio ./config/fio_write_1m.config     >     ./log/${time_start}_1G/fio_write_1m.log
echo ""

echo "./config/fio_read_1m.config"
time fio ./config/fio_read_1m.config     >     ./log/${time_start}_1G/fio_read_1m.log
echo ""

echo "./config/fio_randwrite_04k.config"
time fio ./config/fio_randwrite_04k.config     >     ./log/${time_start}_1G/fio_randwrite_04k.log
echo ""

echo "./config/fio_randread_04k.config"
time fio ./config/fio_randread_04k.config     >     ./log/${time_start}_1G/fio_randread_04k.log
echo ""

echo "./config/fio_randwrite_08k.config"
time fio ./config/fio_randwrite_08k.config     >     ./log/${time_start}_1G/fio_randwrite_08k.log
echo ""

echo "./config/fio_randread_08k.config"
time fio ./config/fio_randread_08k.config     >     ./log/${time_start}_1G/fio_randread_08k.log
echo ""

echo "./config/fio_randwrite_64k.config"
time fio ./config/fio_randwrite_64k.config     >     ./log/${time_start}_1G/fio_randwrite_64k.log
echo ""

echo "./config/fio_randread_64k.config"
time fio ./config/fio_randread_64k.config     >     ./log/${time_start}_1G/fio_randread_64k.log
echo ""


time_stop="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H):$(date +%M):$(date +%S)"
timestamp_stop="$(date +%s)"

echo "time stop:"
echo $time_stop
echo "time stop:" >> ./log/${time_start}_1G/time.log
echo "${time_stop}" >> ./log/${time_start}_1G/time.log
echo "${timestamp_stop}" >> ./log/${time_start}_1G/time.log

echo "time elapse(s):" >> ./log/${time_start}_1G/time.log
echo "scale=4;${timestamp_stop}-${timestamp_start}" | bc >> ./log/${time_start}_1G/time.log

