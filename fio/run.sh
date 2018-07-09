#!/bin/bash
time_start="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H)-$(date +%M)-$(date +%S)"
timestamp_start="$(date +%s)"

echo "time start:"
echo $time_start
echo ""

if [ ! -d ./log ];then
        mkdir ./log
fi

mkdir ./log/${time_start}_2M
cp ./generate.sh ./run.sh ./log/${time_start}_2M
cp -r ./config ./log/${time_start}_2M

echo "time start:" > ./log/${time_start}_2M/time.log
echo "${time_start}" >> ./log/${time_start}_2M/time.log
echo "${timestamp_start}" >> ./log/${time_start}_2M/time.log


echo "./config/fio_write_64k.config"
time fio ./config/fio_write_64k.config     >     ./log/${time_start}_2M/fio_write_64k.log
echo ""

echo "./config/fio_read_64k.config"
time fio ./config/fio_read_64k.config     >     ./log/${time_start}_2M/fio_read_64k.log
echo ""

echo "./config/fio_write_512k.config"
time fio ./config/fio_write_512k.config     >     ./log/${time_start}_2M/fio_write_512k.log
echo ""

echo "./config/fio_read_512k.config"
time fio ./config/fio_read_512k.config     >     ./log/${time_start}_2M/fio_read_512k.log
echo ""

echo "./config/fio_write_1m.config"
time fio ./config/fio_write_1m.config     >     ./log/${time_start}_2M/fio_write_1m.log
echo ""

echo "./config/fio_read_1m.config"
time fio ./config/fio_read_1m.config     >     ./log/${time_start}_2M/fio_read_1m.log
echo ""

echo "./config/fio_randwrite_04k.config"
time fio ./config/fio_randwrite_04k.config     >     ./log/${time_start}_2M/fio_randwrite_04k.log
echo ""

echo "./config/fio_randread_04k.config"
time fio ./config/fio_randread_04k.config     >     ./log/${time_start}_2M/fio_randread_04k.log
echo ""

echo "./config/fio_randwrite_08k.config"
time fio ./config/fio_randwrite_08k.config     >     ./log/${time_start}_2M/fio_randwrite_08k.log
echo ""

echo "./config/fio_randread_08k.config"
time fio ./config/fio_randread_08k.config     >     ./log/${time_start}_2M/fio_randread_08k.log
echo ""

echo "./config/fio_randwrite_64k.config"
time fio ./config/fio_randwrite_64k.config     >     ./log/${time_start}_2M/fio_randwrite_64k.log
echo ""

echo "./config/fio_randread_64k.config"
time fio ./config/fio_randread_64k.config     >     ./log/${time_start}_2M/fio_randread_64k.log
echo ""


time_stop="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H)-$(date +%M)-$(date +%S)"
timestamp_stop="$(date +%s)"

echo "time stop:"
echo $time_stop

echo "" >> ./log/${time_start}_2M/time.log
echo "time stop:" >> ./log/${time_start}_2M/time.log
echo "${time_stop}" >> ./log/${time_start}_2M/time.log
echo "${timestamp_stop}" >> ./log/${time_start}_2M/time.log

echo "" >> ./log/${time_start}_2M/time.log
echo "time elapse:" >> ./log/${time_start}_2M/time.log

sec=$(echo "scale=4;${timestamp_stop}-${timestamp_start}" | bc )
echo "${sec}(s)" >> ./log/${time_start}_2M/time.log

min=$(echo "scale=4;${sec}/60" | bc )
echo "${min}(m)" >> ./log/${time_start}_2M/time.log

hour=$(echo "scale=4;${min}/60" | bc )
echo "${hour}(h)" >> ./log/${time_start}_2M/time.log

echo ""
echo "logdir:"
echo "./log/${time_start}_2M"

