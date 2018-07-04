#!/bin/bash
time_record="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H):$(date +%M):$(date +%S)"

echo $time_record

if [ ! -d ./log ];then
    mkdir ./log
fi

mkdir ./log/${time_record}
cp ./config/generate.sh ./log/${time_record}
cp ./run.sh ./log/${time_record}

fio ./config/fio_write_64k.config           > ./log/${time_record}/fio_write_64k.log
fio ./config/fio_write_512k.config          > ./log/${time_record}/fio_write_512k.log
fio ./config/fio_write_1m.config            > ./log/${time_record}/fio_write_1m.log

fio ./config/fio_read_64k.config            > ./log/${time_record}/fio_read_64k.log
fio ./config/fio_read_512k.config           > ./log/${time_record}/fio_read_512k.log
fio ./config/fio_read_1m.config             > ./log/${time_record}/fio_read_1m.log

fio ./config/fio_randwrite_04k.config       > ./log/${time_record}/fio_randwrite_04k.log
fio ./config/fio_randwrite_08k.config       > ./log/${time_record}/fio_randwrite_08k.log
fio ./config/fio_randwrite_64k.config       > ./log/${time_record}/fio_randwrite_64k.log

fio ./config/fio_randread_04k.config        > ./log/${time_record}/fio_randread_04k.log
fio ./config/fio_randread_08k.config        > ./log/${time_record}/fio_randread_08k.log
fio ./config/fio_randread_64k.config        > ./log/${time_record}/fio_randread_64k.log
