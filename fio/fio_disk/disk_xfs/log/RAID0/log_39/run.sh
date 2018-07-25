#!/bin/bash

    trap '{ echo "Ctrl-C to quit." ; exit 1; }' INT

    _disk_list="sda sdb sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn"
    

    lsblk
    echo ""

    df -Th
    echo ""

    echo -e "these disk will be \033[31mformatted\033[0m, do you want to continue?"
    echo -e "make sure the \033[31mOS disk\033[0m is not one of them!"
    echo -e "\033[47;31m"
    for i in $_disk_list
    do
        echo ${i}
    done
    echo -e "\033[0m"
    echo -e "\033[31;5m[yes/no]?\033[0m"
    while [ 1 ]
    do
        read var
        if [ $var"x" != "yesx" ];then
            echo "you chose no"
            exit 1
        else
            break
        fi
    done

    echo ""
    echo "formatting disk..."
    for i in ${_disk_list}
    do
        echo ${i}
        parted /dev/${i} -s "mklabel msdos"
        parted /dev/${i} -s "mklabel gpt"
    done

    echo ""
    lsblk

    sleep 5

    echo ""
    echo "formatting disk into one primary partition"
    for i in ${_disk_list}
    do
        echo ${i}
        parted /dev/${i} -s "mkpart primary 0 -1"
    done

    echo ""
    lsblk

    sleep 5

    echo ""
    echo "formatting disk with xfs..."
    for i in ${_disk_list}
    do
        echo ${i}
        mkfs.xfs -f /dev/${i}1
        if [ -d /mnt/${i} ];then
            rm -rf /mnt/${i}
        fi
        mkdir /mnt/${i}
        mount /dev/${i}1 /mnt/${i}
    done

    echo ""
    lsblk

    echo ""
    df -Th

    echo -e "\033[47;31m"
    echo -e "make sure the mount is right"
    echo -e "\033[0m"
    echo -e "\033[31;5m[yes/no]?\033[0m"
    while [ 1 ]
    do
        read var
        if [ $var"x" != "yesx" ];then
            echo "you chose no"
            exit 1
        else
            break
        fi
    done



    time_start="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H)-$(date +%M)-$(date +%S)"
    timestamp_start="$(date +%s)"

    echo ""
    echo "time start:"
    echo $time_start
    echo ""
    echo ""
    echo ""
    echo ""

    #create log folder
    if [ -d ./log ];then
        mv ./log bak.${time_start}
    fi
    mkdir ./log

    for i in ${_disk_list}
    do
        mkdir ./log/${i}
    done

    #bakup config file
    cp ./generate.sh ./run.sh ./log
    cp -r ./config ./log

    echo "time start:" > ./log/time.log
    echo "${time_start}" >> ./log/time.log
    echo "${timestamp_start}" >> ./log/time.log

    


    time_start_disk="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H)-$(date +%M)-$(date +%S)"
    timestamp_start_disk="$(date +%s)"

    echo "test on sda time start:"
    echo $time_start_disk
    echo ""

    echo "time start:" > ./log/sda/time.log
    echo "${time_start_disk}" >> ./log/sda/time.log
    echo "${timestamp_start_disk}" >> ./log/sda/time.log

    
    echo "./config/sda/fio_write_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sda/fio_write_64k.log.time fio ./config/sda/fio_write_64k.config  >  ./log/sda/fio_write_64k.log
    echo "./config/sda/fio_read_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sda/fio_read_64k.log.time fio ./config/sda/fio_read_64k.config  >  ./log/sda/fio_read_64k.log
    echo "./config/sda/fio_write_512k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sda/fio_write_512k.log.time fio ./config/sda/fio_write_512k.config  >  ./log/sda/fio_write_512k.log
    echo "./config/sda/fio_read_512k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sda/fio_read_512k.log.time fio ./config/sda/fio_read_512k.config  >  ./log/sda/fio_read_512k.log
    echo "./config/sda/fio_write_1m.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sda/fio_write_1m.log.time fio ./config/sda/fio_write_1m.config  >  ./log/sda/fio_write_1m.log
    echo "./config/sda/fio_read_1m.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sda/fio_read_1m.log.time fio ./config/sda/fio_read_1m.config  >  ./log/sda/fio_read_1m.log
    echo "./config/sda/fio_randwrite_04k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sda/fio_randwrite_04k.log.time fio ./config/sda/fio_randwrite_04k.config  >  ./log/sda/fio_randwrite_04k.log
    echo "./config/sda/fio_randread_04k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sda/fio_randread_04k.log.time fio ./config/sda/fio_randread_04k.config  >  ./log/sda/fio_randread_04k.log
    echo "./config/sda/fio_randwrite_08k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sda/fio_randwrite_08k.log.time fio ./config/sda/fio_randwrite_08k.config  >  ./log/sda/fio_randwrite_08k.log
    echo "./config/sda/fio_randread_08k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sda/fio_randread_08k.log.time fio ./config/sda/fio_randread_08k.config  >  ./log/sda/fio_randread_08k.log
    echo "./config/sda/fio_randwrite_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sda/fio_randwrite_64k.log.time fio ./config/sda/fio_randwrite_64k.config  >  ./log/sda/fio_randwrite_64k.log
    echo "./config/sda/fio_randread_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sda/fio_randread_64k.log.time fio ./config/sda/fio_randread_64k.config  >  ./log/sda/fio_randread_64k.log


    time_stop_disk="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H)-$(date +%M)-$(date +%S)"
    timestamp_stop_disk="$(date +%s)"

    echo ""
    echo "test on sda time stop:"
    echo $time_stop_disk
    echo ""

    echo "" >> ./log/sda/time.log
    echo "test on sda time stop:" >> ./log/sda/time.log
    echo "${time_stop_disk}" >> ./log/sda/time.log
    echo "${timestamp_stop_disk}" >> ./log/sda/time.log
    echo "" >> ./log/sda/time.log

    sec=$(echo "scale=4;${timestamp_stop_disk}-${timestamp_start_disk}" | bc )
    min=$(echo "scale=4;${sec}/60" | bc )
    hour=$(echo "scale=4;${min}/60" | bc )

    echo "time elapse:"
    echo "${sec}(s)"
    echo "${min}(m)"
    echo "${hour}(h)"

    echo "time elapse:" >> ./log/sda/time.log
    echo "${sec}(s)" >> ./log/sda/time.log
    echo "${min}(m)" >> ./log/sda/time.log
    echo "${hour}(h)" >> ./log/sda/time.log

    
    echo ""
    echo ""
    echo ""
    echo ""



    time_start_disk="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H)-$(date +%M)-$(date +%S)"
    timestamp_start_disk="$(date +%s)"

    echo "test on sdb time start:"
    echo $time_start_disk
    echo ""

    echo "time start:" > ./log/sdb/time.log
    echo "${time_start_disk}" >> ./log/sdb/time.log
    echo "${timestamp_start_disk}" >> ./log/sdb/time.log

    
    echo "./config/sdb/fio_write_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdb/fio_write_64k.log.time fio ./config/sdb/fio_write_64k.config  >  ./log/sdb/fio_write_64k.log
    echo "./config/sdb/fio_read_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdb/fio_read_64k.log.time fio ./config/sdb/fio_read_64k.config  >  ./log/sdb/fio_read_64k.log
    echo "./config/sdb/fio_write_512k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdb/fio_write_512k.log.time fio ./config/sdb/fio_write_512k.config  >  ./log/sdb/fio_write_512k.log
    echo "./config/sdb/fio_read_512k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdb/fio_read_512k.log.time fio ./config/sdb/fio_read_512k.config  >  ./log/sdb/fio_read_512k.log
    echo "./config/sdb/fio_write_1m.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdb/fio_write_1m.log.time fio ./config/sdb/fio_write_1m.config  >  ./log/sdb/fio_write_1m.log
    echo "./config/sdb/fio_read_1m.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdb/fio_read_1m.log.time fio ./config/sdb/fio_read_1m.config  >  ./log/sdb/fio_read_1m.log
    echo "./config/sdb/fio_randwrite_04k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdb/fio_randwrite_04k.log.time fio ./config/sdb/fio_randwrite_04k.config  >  ./log/sdb/fio_randwrite_04k.log
    echo "./config/sdb/fio_randread_04k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdb/fio_randread_04k.log.time fio ./config/sdb/fio_randread_04k.config  >  ./log/sdb/fio_randread_04k.log
    echo "./config/sdb/fio_randwrite_08k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdb/fio_randwrite_08k.log.time fio ./config/sdb/fio_randwrite_08k.config  >  ./log/sdb/fio_randwrite_08k.log
    echo "./config/sdb/fio_randread_08k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdb/fio_randread_08k.log.time fio ./config/sdb/fio_randread_08k.config  >  ./log/sdb/fio_randread_08k.log
    echo "./config/sdb/fio_randwrite_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdb/fio_randwrite_64k.log.time fio ./config/sdb/fio_randwrite_64k.config  >  ./log/sdb/fio_randwrite_64k.log
    echo "./config/sdb/fio_randread_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdb/fio_randread_64k.log.time fio ./config/sdb/fio_randread_64k.config  >  ./log/sdb/fio_randread_64k.log


    time_stop_disk="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H)-$(date +%M)-$(date +%S)"
    timestamp_stop_disk="$(date +%s)"

    echo ""
    echo "test on sdb time stop:"
    echo $time_stop_disk
    echo ""

    echo "" >> ./log/sdb/time.log
    echo "test on sdb time stop:" >> ./log/sdb/time.log
    echo "${time_stop_disk}" >> ./log/sdb/time.log
    echo "${timestamp_stop_disk}" >> ./log/sdb/time.log
    echo "" >> ./log/sdb/time.log

    sec=$(echo "scale=4;${timestamp_stop_disk}-${timestamp_start_disk}" | bc )
    min=$(echo "scale=4;${sec}/60" | bc )
    hour=$(echo "scale=4;${min}/60" | bc )

    echo "time elapse:"
    echo "${sec}(s)"
    echo "${min}(m)"
    echo "${hour}(h)"

    echo "time elapse:" >> ./log/sdb/time.log
    echo "${sec}(s)" >> ./log/sdb/time.log
    echo "${min}(m)" >> ./log/sdb/time.log
    echo "${hour}(h)" >> ./log/sdb/time.log

    
    echo ""
    echo ""
    echo ""
    echo ""



    time_start_disk="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H)-$(date +%M)-$(date +%S)"
    timestamp_start_disk="$(date +%s)"

    echo "test on sdd time start:"
    echo $time_start_disk
    echo ""

    echo "time start:" > ./log/sdd/time.log
    echo "${time_start_disk}" >> ./log/sdd/time.log
    echo "${timestamp_start_disk}" >> ./log/sdd/time.log

    
    echo "./config/sdd/fio_write_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdd/fio_write_64k.log.time fio ./config/sdd/fio_write_64k.config  >  ./log/sdd/fio_write_64k.log
    echo "./config/sdd/fio_read_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdd/fio_read_64k.log.time fio ./config/sdd/fio_read_64k.config  >  ./log/sdd/fio_read_64k.log
    echo "./config/sdd/fio_write_512k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdd/fio_write_512k.log.time fio ./config/sdd/fio_write_512k.config  >  ./log/sdd/fio_write_512k.log
    echo "./config/sdd/fio_read_512k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdd/fio_read_512k.log.time fio ./config/sdd/fio_read_512k.config  >  ./log/sdd/fio_read_512k.log
    echo "./config/sdd/fio_write_1m.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdd/fio_write_1m.log.time fio ./config/sdd/fio_write_1m.config  >  ./log/sdd/fio_write_1m.log
    echo "./config/sdd/fio_read_1m.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdd/fio_read_1m.log.time fio ./config/sdd/fio_read_1m.config  >  ./log/sdd/fio_read_1m.log
    echo "./config/sdd/fio_randwrite_04k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdd/fio_randwrite_04k.log.time fio ./config/sdd/fio_randwrite_04k.config  >  ./log/sdd/fio_randwrite_04k.log
    echo "./config/sdd/fio_randread_04k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdd/fio_randread_04k.log.time fio ./config/sdd/fio_randread_04k.config  >  ./log/sdd/fio_randread_04k.log
    echo "./config/sdd/fio_randwrite_08k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdd/fio_randwrite_08k.log.time fio ./config/sdd/fio_randwrite_08k.config  >  ./log/sdd/fio_randwrite_08k.log
    echo "./config/sdd/fio_randread_08k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdd/fio_randread_08k.log.time fio ./config/sdd/fio_randread_08k.config  >  ./log/sdd/fio_randread_08k.log
    echo "./config/sdd/fio_randwrite_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdd/fio_randwrite_64k.log.time fio ./config/sdd/fio_randwrite_64k.config  >  ./log/sdd/fio_randwrite_64k.log
    echo "./config/sdd/fio_randread_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdd/fio_randread_64k.log.time fio ./config/sdd/fio_randread_64k.config  >  ./log/sdd/fio_randread_64k.log


    time_stop_disk="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H)-$(date +%M)-$(date +%S)"
    timestamp_stop_disk="$(date +%s)"

    echo ""
    echo "test on sdd time stop:"
    echo $time_stop_disk
    echo ""

    echo "" >> ./log/sdd/time.log
    echo "test on sdd time stop:" >> ./log/sdd/time.log
    echo "${time_stop_disk}" >> ./log/sdd/time.log
    echo "${timestamp_stop_disk}" >> ./log/sdd/time.log
    echo "" >> ./log/sdd/time.log

    sec=$(echo "scale=4;${timestamp_stop_disk}-${timestamp_start_disk}" | bc )
    min=$(echo "scale=4;${sec}/60" | bc )
    hour=$(echo "scale=4;${min}/60" | bc )

    echo "time elapse:"
    echo "${sec}(s)"
    echo "${min}(m)"
    echo "${hour}(h)"

    echo "time elapse:" >> ./log/sdd/time.log
    echo "${sec}(s)" >> ./log/sdd/time.log
    echo "${min}(m)" >> ./log/sdd/time.log
    echo "${hour}(h)" >> ./log/sdd/time.log

    
    echo ""
    echo ""
    echo ""
    echo ""



    time_start_disk="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H)-$(date +%M)-$(date +%S)"
    timestamp_start_disk="$(date +%s)"

    echo "test on sde time start:"
    echo $time_start_disk
    echo ""

    echo "time start:" > ./log/sde/time.log
    echo "${time_start_disk}" >> ./log/sde/time.log
    echo "${timestamp_start_disk}" >> ./log/sde/time.log

    
    echo "./config/sde/fio_write_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sde/fio_write_64k.log.time fio ./config/sde/fio_write_64k.config  >  ./log/sde/fio_write_64k.log
    echo "./config/sde/fio_read_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sde/fio_read_64k.log.time fio ./config/sde/fio_read_64k.config  >  ./log/sde/fio_read_64k.log
    echo "./config/sde/fio_write_512k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sde/fio_write_512k.log.time fio ./config/sde/fio_write_512k.config  >  ./log/sde/fio_write_512k.log
    echo "./config/sde/fio_read_512k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sde/fio_read_512k.log.time fio ./config/sde/fio_read_512k.config  >  ./log/sde/fio_read_512k.log
    echo "./config/sde/fio_write_1m.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sde/fio_write_1m.log.time fio ./config/sde/fio_write_1m.config  >  ./log/sde/fio_write_1m.log
    echo "./config/sde/fio_read_1m.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sde/fio_read_1m.log.time fio ./config/sde/fio_read_1m.config  >  ./log/sde/fio_read_1m.log
    echo "./config/sde/fio_randwrite_04k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sde/fio_randwrite_04k.log.time fio ./config/sde/fio_randwrite_04k.config  >  ./log/sde/fio_randwrite_04k.log
    echo "./config/sde/fio_randread_04k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sde/fio_randread_04k.log.time fio ./config/sde/fio_randread_04k.config  >  ./log/sde/fio_randread_04k.log
    echo "./config/sde/fio_randwrite_08k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sde/fio_randwrite_08k.log.time fio ./config/sde/fio_randwrite_08k.config  >  ./log/sde/fio_randwrite_08k.log
    echo "./config/sde/fio_randread_08k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sde/fio_randread_08k.log.time fio ./config/sde/fio_randread_08k.config  >  ./log/sde/fio_randread_08k.log
    echo "./config/sde/fio_randwrite_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sde/fio_randwrite_64k.log.time fio ./config/sde/fio_randwrite_64k.config  >  ./log/sde/fio_randwrite_64k.log
    echo "./config/sde/fio_randread_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sde/fio_randread_64k.log.time fio ./config/sde/fio_randread_64k.config  >  ./log/sde/fio_randread_64k.log


    time_stop_disk="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H)-$(date +%M)-$(date +%S)"
    timestamp_stop_disk="$(date +%s)"

    echo ""
    echo "test on sde time stop:"
    echo $time_stop_disk
    echo ""

    echo "" >> ./log/sde/time.log
    echo "test on sde time stop:" >> ./log/sde/time.log
    echo "${time_stop_disk}" >> ./log/sde/time.log
    echo "${timestamp_stop_disk}" >> ./log/sde/time.log
    echo "" >> ./log/sde/time.log

    sec=$(echo "scale=4;${timestamp_stop_disk}-${timestamp_start_disk}" | bc )
    min=$(echo "scale=4;${sec}/60" | bc )
    hour=$(echo "scale=4;${min}/60" | bc )

    echo "time elapse:"
    echo "${sec}(s)"
    echo "${min}(m)"
    echo "${hour}(h)"

    echo "time elapse:" >> ./log/sde/time.log
    echo "${sec}(s)" >> ./log/sde/time.log
    echo "${min}(m)" >> ./log/sde/time.log
    echo "${hour}(h)" >> ./log/sde/time.log

    
    echo ""
    echo ""
    echo ""
    echo ""



    time_start_disk="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H)-$(date +%M)-$(date +%S)"
    timestamp_start_disk="$(date +%s)"

    echo "test on sdf time start:"
    echo $time_start_disk
    echo ""

    echo "time start:" > ./log/sdf/time.log
    echo "${time_start_disk}" >> ./log/sdf/time.log
    echo "${timestamp_start_disk}" >> ./log/sdf/time.log

    
    echo "./config/sdf/fio_write_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdf/fio_write_64k.log.time fio ./config/sdf/fio_write_64k.config  >  ./log/sdf/fio_write_64k.log
    echo "./config/sdf/fio_read_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdf/fio_read_64k.log.time fio ./config/sdf/fio_read_64k.config  >  ./log/sdf/fio_read_64k.log
    echo "./config/sdf/fio_write_512k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdf/fio_write_512k.log.time fio ./config/sdf/fio_write_512k.config  >  ./log/sdf/fio_write_512k.log
    echo "./config/sdf/fio_read_512k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdf/fio_read_512k.log.time fio ./config/sdf/fio_read_512k.config  >  ./log/sdf/fio_read_512k.log
    echo "./config/sdf/fio_write_1m.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdf/fio_write_1m.log.time fio ./config/sdf/fio_write_1m.config  >  ./log/sdf/fio_write_1m.log
    echo "./config/sdf/fio_read_1m.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdf/fio_read_1m.log.time fio ./config/sdf/fio_read_1m.config  >  ./log/sdf/fio_read_1m.log
    echo "./config/sdf/fio_randwrite_04k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdf/fio_randwrite_04k.log.time fio ./config/sdf/fio_randwrite_04k.config  >  ./log/sdf/fio_randwrite_04k.log
    echo "./config/sdf/fio_randread_04k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdf/fio_randread_04k.log.time fio ./config/sdf/fio_randread_04k.config  >  ./log/sdf/fio_randread_04k.log
    echo "./config/sdf/fio_randwrite_08k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdf/fio_randwrite_08k.log.time fio ./config/sdf/fio_randwrite_08k.config  >  ./log/sdf/fio_randwrite_08k.log
    echo "./config/sdf/fio_randread_08k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdf/fio_randread_08k.log.time fio ./config/sdf/fio_randread_08k.config  >  ./log/sdf/fio_randread_08k.log
    echo "./config/sdf/fio_randwrite_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdf/fio_randwrite_64k.log.time fio ./config/sdf/fio_randwrite_64k.config  >  ./log/sdf/fio_randwrite_64k.log
    echo "./config/sdf/fio_randread_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdf/fio_randread_64k.log.time fio ./config/sdf/fio_randread_64k.config  >  ./log/sdf/fio_randread_64k.log


    time_stop_disk="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H)-$(date +%M)-$(date +%S)"
    timestamp_stop_disk="$(date +%s)"

    echo ""
    echo "test on sdf time stop:"
    echo $time_stop_disk
    echo ""

    echo "" >> ./log/sdf/time.log
    echo "test on sdf time stop:" >> ./log/sdf/time.log
    echo "${time_stop_disk}" >> ./log/sdf/time.log
    echo "${timestamp_stop_disk}" >> ./log/sdf/time.log
    echo "" >> ./log/sdf/time.log

    sec=$(echo "scale=4;${timestamp_stop_disk}-${timestamp_start_disk}" | bc )
    min=$(echo "scale=4;${sec}/60" | bc )
    hour=$(echo "scale=4;${min}/60" | bc )

    echo "time elapse:"
    echo "${sec}(s)"
    echo "${min}(m)"
    echo "${hour}(h)"

    echo "time elapse:" >> ./log/sdf/time.log
    echo "${sec}(s)" >> ./log/sdf/time.log
    echo "${min}(m)" >> ./log/sdf/time.log
    echo "${hour}(h)" >> ./log/sdf/time.log

    
    echo ""
    echo ""
    echo ""
    echo ""



    time_start_disk="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H)-$(date +%M)-$(date +%S)"
    timestamp_start_disk="$(date +%s)"

    echo "test on sdg time start:"
    echo $time_start_disk
    echo ""

    echo "time start:" > ./log/sdg/time.log
    echo "${time_start_disk}" >> ./log/sdg/time.log
    echo "${timestamp_start_disk}" >> ./log/sdg/time.log

    
    echo "./config/sdg/fio_write_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdg/fio_write_64k.log.time fio ./config/sdg/fio_write_64k.config  >  ./log/sdg/fio_write_64k.log
    echo "./config/sdg/fio_read_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdg/fio_read_64k.log.time fio ./config/sdg/fio_read_64k.config  >  ./log/sdg/fio_read_64k.log
    echo "./config/sdg/fio_write_512k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdg/fio_write_512k.log.time fio ./config/sdg/fio_write_512k.config  >  ./log/sdg/fio_write_512k.log
    echo "./config/sdg/fio_read_512k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdg/fio_read_512k.log.time fio ./config/sdg/fio_read_512k.config  >  ./log/sdg/fio_read_512k.log
    echo "./config/sdg/fio_write_1m.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdg/fio_write_1m.log.time fio ./config/sdg/fio_write_1m.config  >  ./log/sdg/fio_write_1m.log
    echo "./config/sdg/fio_read_1m.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdg/fio_read_1m.log.time fio ./config/sdg/fio_read_1m.config  >  ./log/sdg/fio_read_1m.log
    echo "./config/sdg/fio_randwrite_04k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdg/fio_randwrite_04k.log.time fio ./config/sdg/fio_randwrite_04k.config  >  ./log/sdg/fio_randwrite_04k.log
    echo "./config/sdg/fio_randread_04k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdg/fio_randread_04k.log.time fio ./config/sdg/fio_randread_04k.config  >  ./log/sdg/fio_randread_04k.log
    echo "./config/sdg/fio_randwrite_08k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdg/fio_randwrite_08k.log.time fio ./config/sdg/fio_randwrite_08k.config  >  ./log/sdg/fio_randwrite_08k.log
    echo "./config/sdg/fio_randread_08k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdg/fio_randread_08k.log.time fio ./config/sdg/fio_randread_08k.config  >  ./log/sdg/fio_randread_08k.log
    echo "./config/sdg/fio_randwrite_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdg/fio_randwrite_64k.log.time fio ./config/sdg/fio_randwrite_64k.config  >  ./log/sdg/fio_randwrite_64k.log
    echo "./config/sdg/fio_randread_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdg/fio_randread_64k.log.time fio ./config/sdg/fio_randread_64k.config  >  ./log/sdg/fio_randread_64k.log


    time_stop_disk="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H)-$(date +%M)-$(date +%S)"
    timestamp_stop_disk="$(date +%s)"

    echo ""
    echo "test on sdg time stop:"
    echo $time_stop_disk
    echo ""

    echo "" >> ./log/sdg/time.log
    echo "test on sdg time stop:" >> ./log/sdg/time.log
    echo "${time_stop_disk}" >> ./log/sdg/time.log
    echo "${timestamp_stop_disk}" >> ./log/sdg/time.log
    echo "" >> ./log/sdg/time.log

    sec=$(echo "scale=4;${timestamp_stop_disk}-${timestamp_start_disk}" | bc )
    min=$(echo "scale=4;${sec}/60" | bc )
    hour=$(echo "scale=4;${min}/60" | bc )

    echo "time elapse:"
    echo "${sec}(s)"
    echo "${min}(m)"
    echo "${hour}(h)"

    echo "time elapse:" >> ./log/sdg/time.log
    echo "${sec}(s)" >> ./log/sdg/time.log
    echo "${min}(m)" >> ./log/sdg/time.log
    echo "${hour}(h)" >> ./log/sdg/time.log

    
    echo ""
    echo ""
    echo ""
    echo ""



    time_start_disk="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H)-$(date +%M)-$(date +%S)"
    timestamp_start_disk="$(date +%s)"

    echo "test on sdh time start:"
    echo $time_start_disk
    echo ""

    echo "time start:" > ./log/sdh/time.log
    echo "${time_start_disk}" >> ./log/sdh/time.log
    echo "${timestamp_start_disk}" >> ./log/sdh/time.log

    
    echo "./config/sdh/fio_write_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdh/fio_write_64k.log.time fio ./config/sdh/fio_write_64k.config  >  ./log/sdh/fio_write_64k.log
    echo "./config/sdh/fio_read_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdh/fio_read_64k.log.time fio ./config/sdh/fio_read_64k.config  >  ./log/sdh/fio_read_64k.log
    echo "./config/sdh/fio_write_512k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdh/fio_write_512k.log.time fio ./config/sdh/fio_write_512k.config  >  ./log/sdh/fio_write_512k.log
    echo "./config/sdh/fio_read_512k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdh/fio_read_512k.log.time fio ./config/sdh/fio_read_512k.config  >  ./log/sdh/fio_read_512k.log
    echo "./config/sdh/fio_write_1m.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdh/fio_write_1m.log.time fio ./config/sdh/fio_write_1m.config  >  ./log/sdh/fio_write_1m.log
    echo "./config/sdh/fio_read_1m.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdh/fio_read_1m.log.time fio ./config/sdh/fio_read_1m.config  >  ./log/sdh/fio_read_1m.log
    echo "./config/sdh/fio_randwrite_04k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdh/fio_randwrite_04k.log.time fio ./config/sdh/fio_randwrite_04k.config  >  ./log/sdh/fio_randwrite_04k.log
    echo "./config/sdh/fio_randread_04k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdh/fio_randread_04k.log.time fio ./config/sdh/fio_randread_04k.config  >  ./log/sdh/fio_randread_04k.log
    echo "./config/sdh/fio_randwrite_08k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdh/fio_randwrite_08k.log.time fio ./config/sdh/fio_randwrite_08k.config  >  ./log/sdh/fio_randwrite_08k.log
    echo "./config/sdh/fio_randread_08k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdh/fio_randread_08k.log.time fio ./config/sdh/fio_randread_08k.config  >  ./log/sdh/fio_randread_08k.log
    echo "./config/sdh/fio_randwrite_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdh/fio_randwrite_64k.log.time fio ./config/sdh/fio_randwrite_64k.config  >  ./log/sdh/fio_randwrite_64k.log
    echo "./config/sdh/fio_randread_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdh/fio_randread_64k.log.time fio ./config/sdh/fio_randread_64k.config  >  ./log/sdh/fio_randread_64k.log


    time_stop_disk="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H)-$(date +%M)-$(date +%S)"
    timestamp_stop_disk="$(date +%s)"

    echo ""
    echo "test on sdh time stop:"
    echo $time_stop_disk
    echo ""

    echo "" >> ./log/sdh/time.log
    echo "test on sdh time stop:" >> ./log/sdh/time.log
    echo "${time_stop_disk}" >> ./log/sdh/time.log
    echo "${timestamp_stop_disk}" >> ./log/sdh/time.log
    echo "" >> ./log/sdh/time.log

    sec=$(echo "scale=4;${timestamp_stop_disk}-${timestamp_start_disk}" | bc )
    min=$(echo "scale=4;${sec}/60" | bc )
    hour=$(echo "scale=4;${min}/60" | bc )

    echo "time elapse:"
    echo "${sec}(s)"
    echo "${min}(m)"
    echo "${hour}(h)"

    echo "time elapse:" >> ./log/sdh/time.log
    echo "${sec}(s)" >> ./log/sdh/time.log
    echo "${min}(m)" >> ./log/sdh/time.log
    echo "${hour}(h)" >> ./log/sdh/time.log

    
    echo ""
    echo ""
    echo ""
    echo ""



    time_start_disk="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H)-$(date +%M)-$(date +%S)"
    timestamp_start_disk="$(date +%s)"

    echo "test on sdi time start:"
    echo $time_start_disk
    echo ""

    echo "time start:" > ./log/sdi/time.log
    echo "${time_start_disk}" >> ./log/sdi/time.log
    echo "${timestamp_start_disk}" >> ./log/sdi/time.log

    
    echo "./config/sdi/fio_write_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdi/fio_write_64k.log.time fio ./config/sdi/fio_write_64k.config  >  ./log/sdi/fio_write_64k.log
    echo "./config/sdi/fio_read_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdi/fio_read_64k.log.time fio ./config/sdi/fio_read_64k.config  >  ./log/sdi/fio_read_64k.log
    echo "./config/sdi/fio_write_512k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdi/fio_write_512k.log.time fio ./config/sdi/fio_write_512k.config  >  ./log/sdi/fio_write_512k.log
    echo "./config/sdi/fio_read_512k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdi/fio_read_512k.log.time fio ./config/sdi/fio_read_512k.config  >  ./log/sdi/fio_read_512k.log
    echo "./config/sdi/fio_write_1m.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdi/fio_write_1m.log.time fio ./config/sdi/fio_write_1m.config  >  ./log/sdi/fio_write_1m.log
    echo "./config/sdi/fio_read_1m.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdi/fio_read_1m.log.time fio ./config/sdi/fio_read_1m.config  >  ./log/sdi/fio_read_1m.log
    echo "./config/sdi/fio_randwrite_04k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdi/fio_randwrite_04k.log.time fio ./config/sdi/fio_randwrite_04k.config  >  ./log/sdi/fio_randwrite_04k.log
    echo "./config/sdi/fio_randread_04k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdi/fio_randread_04k.log.time fio ./config/sdi/fio_randread_04k.config  >  ./log/sdi/fio_randread_04k.log
    echo "./config/sdi/fio_randwrite_08k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdi/fio_randwrite_08k.log.time fio ./config/sdi/fio_randwrite_08k.config  >  ./log/sdi/fio_randwrite_08k.log
    echo "./config/sdi/fio_randread_08k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdi/fio_randread_08k.log.time fio ./config/sdi/fio_randread_08k.config  >  ./log/sdi/fio_randread_08k.log
    echo "./config/sdi/fio_randwrite_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdi/fio_randwrite_64k.log.time fio ./config/sdi/fio_randwrite_64k.config  >  ./log/sdi/fio_randwrite_64k.log
    echo "./config/sdi/fio_randread_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdi/fio_randread_64k.log.time fio ./config/sdi/fio_randread_64k.config  >  ./log/sdi/fio_randread_64k.log


    time_stop_disk="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H)-$(date +%M)-$(date +%S)"
    timestamp_stop_disk="$(date +%s)"

    echo ""
    echo "test on sdi time stop:"
    echo $time_stop_disk
    echo ""

    echo "" >> ./log/sdi/time.log
    echo "test on sdi time stop:" >> ./log/sdi/time.log
    echo "${time_stop_disk}" >> ./log/sdi/time.log
    echo "${timestamp_stop_disk}" >> ./log/sdi/time.log
    echo "" >> ./log/sdi/time.log

    sec=$(echo "scale=4;${timestamp_stop_disk}-${timestamp_start_disk}" | bc )
    min=$(echo "scale=4;${sec}/60" | bc )
    hour=$(echo "scale=4;${min}/60" | bc )

    echo "time elapse:"
    echo "${sec}(s)"
    echo "${min}(m)"
    echo "${hour}(h)"

    echo "time elapse:" >> ./log/sdi/time.log
    echo "${sec}(s)" >> ./log/sdi/time.log
    echo "${min}(m)" >> ./log/sdi/time.log
    echo "${hour}(h)" >> ./log/sdi/time.log

    
    echo ""
    echo ""
    echo ""
    echo ""



    time_start_disk="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H)-$(date +%M)-$(date +%S)"
    timestamp_start_disk="$(date +%s)"

    echo "test on sdj time start:"
    echo $time_start_disk
    echo ""

    echo "time start:" > ./log/sdj/time.log
    echo "${time_start_disk}" >> ./log/sdj/time.log
    echo "${timestamp_start_disk}" >> ./log/sdj/time.log

    
    echo "./config/sdj/fio_write_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdj/fio_write_64k.log.time fio ./config/sdj/fio_write_64k.config  >  ./log/sdj/fio_write_64k.log
    echo "./config/sdj/fio_read_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdj/fio_read_64k.log.time fio ./config/sdj/fio_read_64k.config  >  ./log/sdj/fio_read_64k.log
    echo "./config/sdj/fio_write_512k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdj/fio_write_512k.log.time fio ./config/sdj/fio_write_512k.config  >  ./log/sdj/fio_write_512k.log
    echo "./config/sdj/fio_read_512k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdj/fio_read_512k.log.time fio ./config/sdj/fio_read_512k.config  >  ./log/sdj/fio_read_512k.log
    echo "./config/sdj/fio_write_1m.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdj/fio_write_1m.log.time fio ./config/sdj/fio_write_1m.config  >  ./log/sdj/fio_write_1m.log
    echo "./config/sdj/fio_read_1m.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdj/fio_read_1m.log.time fio ./config/sdj/fio_read_1m.config  >  ./log/sdj/fio_read_1m.log
    echo "./config/sdj/fio_randwrite_04k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdj/fio_randwrite_04k.log.time fio ./config/sdj/fio_randwrite_04k.config  >  ./log/sdj/fio_randwrite_04k.log
    echo "./config/sdj/fio_randread_04k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdj/fio_randread_04k.log.time fio ./config/sdj/fio_randread_04k.config  >  ./log/sdj/fio_randread_04k.log
    echo "./config/sdj/fio_randwrite_08k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdj/fio_randwrite_08k.log.time fio ./config/sdj/fio_randwrite_08k.config  >  ./log/sdj/fio_randwrite_08k.log
    echo "./config/sdj/fio_randread_08k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdj/fio_randread_08k.log.time fio ./config/sdj/fio_randread_08k.config  >  ./log/sdj/fio_randread_08k.log
    echo "./config/sdj/fio_randwrite_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdj/fio_randwrite_64k.log.time fio ./config/sdj/fio_randwrite_64k.config  >  ./log/sdj/fio_randwrite_64k.log
    echo "./config/sdj/fio_randread_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdj/fio_randread_64k.log.time fio ./config/sdj/fio_randread_64k.config  >  ./log/sdj/fio_randread_64k.log


    time_stop_disk="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H)-$(date +%M)-$(date +%S)"
    timestamp_stop_disk="$(date +%s)"

    echo ""
    echo "test on sdj time stop:"
    echo $time_stop_disk
    echo ""

    echo "" >> ./log/sdj/time.log
    echo "test on sdj time stop:" >> ./log/sdj/time.log
    echo "${time_stop_disk}" >> ./log/sdj/time.log
    echo "${timestamp_stop_disk}" >> ./log/sdj/time.log
    echo "" >> ./log/sdj/time.log

    sec=$(echo "scale=4;${timestamp_stop_disk}-${timestamp_start_disk}" | bc )
    min=$(echo "scale=4;${sec}/60" | bc )
    hour=$(echo "scale=4;${min}/60" | bc )

    echo "time elapse:"
    echo "${sec}(s)"
    echo "${min}(m)"
    echo "${hour}(h)"

    echo "time elapse:" >> ./log/sdj/time.log
    echo "${sec}(s)" >> ./log/sdj/time.log
    echo "${min}(m)" >> ./log/sdj/time.log
    echo "${hour}(h)" >> ./log/sdj/time.log

    
    echo ""
    echo ""
    echo ""
    echo ""



    time_start_disk="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H)-$(date +%M)-$(date +%S)"
    timestamp_start_disk="$(date +%s)"

    echo "test on sdk time start:"
    echo $time_start_disk
    echo ""

    echo "time start:" > ./log/sdk/time.log
    echo "${time_start_disk}" >> ./log/sdk/time.log
    echo "${timestamp_start_disk}" >> ./log/sdk/time.log

    
    echo "./config/sdk/fio_write_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdk/fio_write_64k.log.time fio ./config/sdk/fio_write_64k.config  >  ./log/sdk/fio_write_64k.log
    echo "./config/sdk/fio_read_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdk/fio_read_64k.log.time fio ./config/sdk/fio_read_64k.config  >  ./log/sdk/fio_read_64k.log
    echo "./config/sdk/fio_write_512k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdk/fio_write_512k.log.time fio ./config/sdk/fio_write_512k.config  >  ./log/sdk/fio_write_512k.log
    echo "./config/sdk/fio_read_512k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdk/fio_read_512k.log.time fio ./config/sdk/fio_read_512k.config  >  ./log/sdk/fio_read_512k.log
    echo "./config/sdk/fio_write_1m.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdk/fio_write_1m.log.time fio ./config/sdk/fio_write_1m.config  >  ./log/sdk/fio_write_1m.log
    echo "./config/sdk/fio_read_1m.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdk/fio_read_1m.log.time fio ./config/sdk/fio_read_1m.config  >  ./log/sdk/fio_read_1m.log
    echo "./config/sdk/fio_randwrite_04k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdk/fio_randwrite_04k.log.time fio ./config/sdk/fio_randwrite_04k.config  >  ./log/sdk/fio_randwrite_04k.log
    echo "./config/sdk/fio_randread_04k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdk/fio_randread_04k.log.time fio ./config/sdk/fio_randread_04k.config  >  ./log/sdk/fio_randread_04k.log
    echo "./config/sdk/fio_randwrite_08k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdk/fio_randwrite_08k.log.time fio ./config/sdk/fio_randwrite_08k.config  >  ./log/sdk/fio_randwrite_08k.log
    echo "./config/sdk/fio_randread_08k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdk/fio_randread_08k.log.time fio ./config/sdk/fio_randread_08k.config  >  ./log/sdk/fio_randread_08k.log
    echo "./config/sdk/fio_randwrite_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdk/fio_randwrite_64k.log.time fio ./config/sdk/fio_randwrite_64k.config  >  ./log/sdk/fio_randwrite_64k.log
    echo "./config/sdk/fio_randread_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdk/fio_randread_64k.log.time fio ./config/sdk/fio_randread_64k.config  >  ./log/sdk/fio_randread_64k.log


    time_stop_disk="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H)-$(date +%M)-$(date +%S)"
    timestamp_stop_disk="$(date +%s)"

    echo ""
    echo "test on sdk time stop:"
    echo $time_stop_disk
    echo ""

    echo "" >> ./log/sdk/time.log
    echo "test on sdk time stop:" >> ./log/sdk/time.log
    echo "${time_stop_disk}" >> ./log/sdk/time.log
    echo "${timestamp_stop_disk}" >> ./log/sdk/time.log
    echo "" >> ./log/sdk/time.log

    sec=$(echo "scale=4;${timestamp_stop_disk}-${timestamp_start_disk}" | bc )
    min=$(echo "scale=4;${sec}/60" | bc )
    hour=$(echo "scale=4;${min}/60" | bc )

    echo "time elapse:"
    echo "${sec}(s)"
    echo "${min}(m)"
    echo "${hour}(h)"

    echo "time elapse:" >> ./log/sdk/time.log
    echo "${sec}(s)" >> ./log/sdk/time.log
    echo "${min}(m)" >> ./log/sdk/time.log
    echo "${hour}(h)" >> ./log/sdk/time.log

    
    echo ""
    echo ""
    echo ""
    echo ""



    time_start_disk="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H)-$(date +%M)-$(date +%S)"
    timestamp_start_disk="$(date +%s)"

    echo "test on sdl time start:"
    echo $time_start_disk
    echo ""

    echo "time start:" > ./log/sdl/time.log
    echo "${time_start_disk}" >> ./log/sdl/time.log
    echo "${timestamp_start_disk}" >> ./log/sdl/time.log

    
    echo "./config/sdl/fio_write_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdl/fio_write_64k.log.time fio ./config/sdl/fio_write_64k.config  >  ./log/sdl/fio_write_64k.log
    echo "./config/sdl/fio_read_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdl/fio_read_64k.log.time fio ./config/sdl/fio_read_64k.config  >  ./log/sdl/fio_read_64k.log
    echo "./config/sdl/fio_write_512k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdl/fio_write_512k.log.time fio ./config/sdl/fio_write_512k.config  >  ./log/sdl/fio_write_512k.log
    echo "./config/sdl/fio_read_512k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdl/fio_read_512k.log.time fio ./config/sdl/fio_read_512k.config  >  ./log/sdl/fio_read_512k.log
    echo "./config/sdl/fio_write_1m.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdl/fio_write_1m.log.time fio ./config/sdl/fio_write_1m.config  >  ./log/sdl/fio_write_1m.log
    echo "./config/sdl/fio_read_1m.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdl/fio_read_1m.log.time fio ./config/sdl/fio_read_1m.config  >  ./log/sdl/fio_read_1m.log
    echo "./config/sdl/fio_randwrite_04k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdl/fio_randwrite_04k.log.time fio ./config/sdl/fio_randwrite_04k.config  >  ./log/sdl/fio_randwrite_04k.log
    echo "./config/sdl/fio_randread_04k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdl/fio_randread_04k.log.time fio ./config/sdl/fio_randread_04k.config  >  ./log/sdl/fio_randread_04k.log
    echo "./config/sdl/fio_randwrite_08k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdl/fio_randwrite_08k.log.time fio ./config/sdl/fio_randwrite_08k.config  >  ./log/sdl/fio_randwrite_08k.log
    echo "./config/sdl/fio_randread_08k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdl/fio_randread_08k.log.time fio ./config/sdl/fio_randread_08k.config  >  ./log/sdl/fio_randread_08k.log
    echo "./config/sdl/fio_randwrite_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdl/fio_randwrite_64k.log.time fio ./config/sdl/fio_randwrite_64k.config  >  ./log/sdl/fio_randwrite_64k.log
    echo "./config/sdl/fio_randread_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdl/fio_randread_64k.log.time fio ./config/sdl/fio_randread_64k.config  >  ./log/sdl/fio_randread_64k.log


    time_stop_disk="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H)-$(date +%M)-$(date +%S)"
    timestamp_stop_disk="$(date +%s)"

    echo ""
    echo "test on sdl time stop:"
    echo $time_stop_disk
    echo ""

    echo "" >> ./log/sdl/time.log
    echo "test on sdl time stop:" >> ./log/sdl/time.log
    echo "${time_stop_disk}" >> ./log/sdl/time.log
    echo "${timestamp_stop_disk}" >> ./log/sdl/time.log
    echo "" >> ./log/sdl/time.log

    sec=$(echo "scale=4;${timestamp_stop_disk}-${timestamp_start_disk}" | bc )
    min=$(echo "scale=4;${sec}/60" | bc )
    hour=$(echo "scale=4;${min}/60" | bc )

    echo "time elapse:"
    echo "${sec}(s)"
    echo "${min}(m)"
    echo "${hour}(h)"

    echo "time elapse:" >> ./log/sdl/time.log
    echo "${sec}(s)" >> ./log/sdl/time.log
    echo "${min}(m)" >> ./log/sdl/time.log
    echo "${hour}(h)" >> ./log/sdl/time.log

    
    echo ""
    echo ""
    echo ""
    echo ""



    time_start_disk="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H)-$(date +%M)-$(date +%S)"
    timestamp_start_disk="$(date +%s)"

    echo "test on sdm time start:"
    echo $time_start_disk
    echo ""

    echo "time start:" > ./log/sdm/time.log
    echo "${time_start_disk}" >> ./log/sdm/time.log
    echo "${timestamp_start_disk}" >> ./log/sdm/time.log

    
    echo "./config/sdm/fio_write_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdm/fio_write_64k.log.time fio ./config/sdm/fio_write_64k.config  >  ./log/sdm/fio_write_64k.log
    echo "./config/sdm/fio_read_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdm/fio_read_64k.log.time fio ./config/sdm/fio_read_64k.config  >  ./log/sdm/fio_read_64k.log
    echo "./config/sdm/fio_write_512k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdm/fio_write_512k.log.time fio ./config/sdm/fio_write_512k.config  >  ./log/sdm/fio_write_512k.log
    echo "./config/sdm/fio_read_512k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdm/fio_read_512k.log.time fio ./config/sdm/fio_read_512k.config  >  ./log/sdm/fio_read_512k.log
    echo "./config/sdm/fio_write_1m.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdm/fio_write_1m.log.time fio ./config/sdm/fio_write_1m.config  >  ./log/sdm/fio_write_1m.log
    echo "./config/sdm/fio_read_1m.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdm/fio_read_1m.log.time fio ./config/sdm/fio_read_1m.config  >  ./log/sdm/fio_read_1m.log
    echo "./config/sdm/fio_randwrite_04k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdm/fio_randwrite_04k.log.time fio ./config/sdm/fio_randwrite_04k.config  >  ./log/sdm/fio_randwrite_04k.log
    echo "./config/sdm/fio_randread_04k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdm/fio_randread_04k.log.time fio ./config/sdm/fio_randread_04k.config  >  ./log/sdm/fio_randread_04k.log
    echo "./config/sdm/fio_randwrite_08k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdm/fio_randwrite_08k.log.time fio ./config/sdm/fio_randwrite_08k.config  >  ./log/sdm/fio_randwrite_08k.log
    echo "./config/sdm/fio_randread_08k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdm/fio_randread_08k.log.time fio ./config/sdm/fio_randread_08k.config  >  ./log/sdm/fio_randread_08k.log
    echo "./config/sdm/fio_randwrite_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdm/fio_randwrite_64k.log.time fio ./config/sdm/fio_randwrite_64k.config  >  ./log/sdm/fio_randwrite_64k.log
    echo "./config/sdm/fio_randread_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdm/fio_randread_64k.log.time fio ./config/sdm/fio_randread_64k.config  >  ./log/sdm/fio_randread_64k.log


    time_stop_disk="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H)-$(date +%M)-$(date +%S)"
    timestamp_stop_disk="$(date +%s)"

    echo ""
    echo "test on sdm time stop:"
    echo $time_stop_disk
    echo ""

    echo "" >> ./log/sdm/time.log
    echo "test on sdm time stop:" >> ./log/sdm/time.log
    echo "${time_stop_disk}" >> ./log/sdm/time.log
    echo "${timestamp_stop_disk}" >> ./log/sdm/time.log
    echo "" >> ./log/sdm/time.log

    sec=$(echo "scale=4;${timestamp_stop_disk}-${timestamp_start_disk}" | bc )
    min=$(echo "scale=4;${sec}/60" | bc )
    hour=$(echo "scale=4;${min}/60" | bc )

    echo "time elapse:"
    echo "${sec}(s)"
    echo "${min}(m)"
    echo "${hour}(h)"

    echo "time elapse:" >> ./log/sdm/time.log
    echo "${sec}(s)" >> ./log/sdm/time.log
    echo "${min}(m)" >> ./log/sdm/time.log
    echo "${hour}(h)" >> ./log/sdm/time.log

    
    echo ""
    echo ""
    echo ""
    echo ""



    time_start_disk="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H)-$(date +%M)-$(date +%S)"
    timestamp_start_disk="$(date +%s)"

    echo "test on sdn time start:"
    echo $time_start_disk
    echo ""

    echo "time start:" > ./log/sdn/time.log
    echo "${time_start_disk}" >> ./log/sdn/time.log
    echo "${timestamp_start_disk}" >> ./log/sdn/time.log

    
    echo "./config/sdn/fio_write_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdn/fio_write_64k.log.time fio ./config/sdn/fio_write_64k.config  >  ./log/sdn/fio_write_64k.log
    echo "./config/sdn/fio_read_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdn/fio_read_64k.log.time fio ./config/sdn/fio_read_64k.config  >  ./log/sdn/fio_read_64k.log
    echo "./config/sdn/fio_write_512k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdn/fio_write_512k.log.time fio ./config/sdn/fio_write_512k.config  >  ./log/sdn/fio_write_512k.log
    echo "./config/sdn/fio_read_512k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdn/fio_read_512k.log.time fio ./config/sdn/fio_read_512k.config  >  ./log/sdn/fio_read_512k.log
    echo "./config/sdn/fio_write_1m.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdn/fio_write_1m.log.time fio ./config/sdn/fio_write_1m.config  >  ./log/sdn/fio_write_1m.log
    echo "./config/sdn/fio_read_1m.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdn/fio_read_1m.log.time fio ./config/sdn/fio_read_1m.config  >  ./log/sdn/fio_read_1m.log
    echo "./config/sdn/fio_randwrite_04k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdn/fio_randwrite_04k.log.time fio ./config/sdn/fio_randwrite_04k.config  >  ./log/sdn/fio_randwrite_04k.log
    echo "./config/sdn/fio_randread_04k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdn/fio_randread_04k.log.time fio ./config/sdn/fio_randread_04k.config  >  ./log/sdn/fio_randread_04k.log
    echo "./config/sdn/fio_randwrite_08k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdn/fio_randwrite_08k.log.time fio ./config/sdn/fio_randwrite_08k.config  >  ./log/sdn/fio_randwrite_08k.log
    echo "./config/sdn/fio_randread_08k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdn/fio_randread_08k.log.time fio ./config/sdn/fio_randread_08k.config  >  ./log/sdn/fio_randread_08k.log
    echo "./config/sdn/fio_randwrite_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdn/fio_randwrite_64k.log.time fio ./config/sdn/fio_randwrite_64k.config  >  ./log/sdn/fio_randwrite_64k.log
    echo "./config/sdn/fio_randread_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/sdn/fio_randread_64k.log.time fio ./config/sdn/fio_randread_64k.config  >  ./log/sdn/fio_randread_64k.log


    time_stop_disk="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H)-$(date +%M)-$(date +%S)"
    timestamp_stop_disk="$(date +%s)"

    echo ""
    echo "test on sdn time stop:"
    echo $time_stop_disk
    echo ""

    echo "" >> ./log/sdn/time.log
    echo "test on sdn time stop:" >> ./log/sdn/time.log
    echo "${time_stop_disk}" >> ./log/sdn/time.log
    echo "${timestamp_stop_disk}" >> ./log/sdn/time.log
    echo "" >> ./log/sdn/time.log

    sec=$(echo "scale=4;${timestamp_stop_disk}-${timestamp_start_disk}" | bc )
    min=$(echo "scale=4;${sec}/60" | bc )
    hour=$(echo "scale=4;${min}/60" | bc )

    echo "time elapse:"
    echo "${sec}(s)"
    echo "${min}(m)"
    echo "${hour}(h)"

    echo "time elapse:" >> ./log/sdn/time.log
    echo "${sec}(s)" >> ./log/sdn/time.log
    echo "${min}(m)" >> ./log/sdn/time.log
    echo "${hour}(h)" >> ./log/sdn/time.log

    
    echo ""
    echo ""
    echo ""
    echo ""


    echo ""
    echo ""
    echo ""
    echo ""
    time_stop="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H)-$(date +%M)-$(date +%S)"
    timestamp_stop="$(date +%s)"

    echo "" >> ./log/time.log
    echo "time stop:" >> ./log/time.log
    echo "${time_stop}" >> ./log/time.log
    echo "${timestamp_stop}" >> ./log/time.log
    echo "" >> ./log/time.log

    sec=$(echo "scale=4;${timestamp_stop}-${timestamp_start}" | bc )
    min=$(echo "scale=4;${sec}/60" | bc )
    hour=$(echo "scale=4;${min}/60" | bc )

    echo "time elapse:" >> ./log/time.log
    echo "${sec}(s)" >> ./log/time.log
    echo "${min}(m)" >> ./log/time.log
    echo "${hour}(h)" >> ./log/time.log

    echo ""
    echo "logdir:"
    echo "./log"

    echo ""
    echo "time start:"
    echo $time_start
    echo ""
    echo "time stop:"
    echo $time_stop

    echo ""
    echo "time elapse:"
    echo "${sec}(s)"
    echo "${min}(m)"
    echo "${hour}(h)"

    for i in ${_disk_list}
    do
        echo ${i}
        umount /mnt/${i}
        rm -rf /mnt/${i}
    done

    
