#!/bin/bash
time_record="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H):$(date +%M):$(date +%S)"

echo $time_record
echo ""

if [ ! -d ./log ];then
        mkdir ./log
    fi

    mkdir ./log/${time_record}_20G
    cp ./generate.sh ./run.sh ./log/${time_record}_20G


echo "./config/fio_write_64k.config"
time fio ./config/fio_write_64k.config     >     ./log/${time_record}_20G/fio_write_64k.log
echo ""

echo "./config/fio_read_64k.config"
time fio ./config/fio_read_64k.config     >     ./log/${time_record}_20G/fio_read_64k.log
echo ""

echo "./config/fio_write_512k.config"
time fio ./config/fio_write_512k.config     >     ./log/${time_record}_20G/fio_write_512k.log
echo ""

echo "./config/fio_read_512k.config"
time fio ./config/fio_read_512k.config     >     ./log/${time_record}_20G/fio_read_512k.log
echo ""

echo "./config/fio_write_1m.config"
time fio ./config/fio_write_1m.config     >     ./log/${time_record}_20G/fio_write_1m.log
echo ""

echo "./config/fio_read_1m.config"
time fio ./config/fio_read_1m.config     >     ./log/${time_record}_20G/fio_read_1m.log
echo ""

echo "./config/fio_randwrite_04k.config"
time fio ./config/fio_randwrite_04k.config     >     ./log/${time_record}_20G/fio_randwrite_04k.log
echo ""

echo "./config/fio_randread_04k.config"
time fio ./config/fio_randread_04k.config     >     ./log/${time_record}_20G/fio_randread_04k.log
echo ""

echo "./config/fio_randwrite_08k.config"
time fio ./config/fio_randwrite_08k.config     >     ./log/${time_record}_20G/fio_randwrite_08k.log
echo ""

echo "./config/fio_randread_08k.config"
time fio ./config/fio_randread_08k.config     >     ./log/${time_record}_20G/fio_randread_08k.log
echo ""

echo "./config/fio_randwrite_64k.config"
time fio ./config/fio_randwrite_64k.config     >     ./log/${time_record}_20G/fio_randwrite_64k.log
echo ""

echo "./config/fio_randread_64k.config"
time fio ./config/fio_randread_64k.config     >     ./log/${time_record}_20G/fio_randread_64k.log
echo ""

