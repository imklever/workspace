#!/bin/bash

    trap '{ echo "Ctrl-C to quit." ; exit 1; }' INT

    _disk_list="sdk sdl sdm sdn"
    

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
        parted /dev/${i} -s "mkpart primary xfs 0 -1"
        mkfs.xfs -f /dev/sdn1
        mkdir /mnt/sdn
        mount -t /dev/sdn1 /mnt/sdn
    done
    echo ""

    lsblk

    time_start="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H)-$(date +%M)-$(date +%S)"
    timestamp_start="$(date +%s)"

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

    echo "test on sdk time stop:" > ./log/sdk/time.log
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

    echo "test on sdl time stop:" > ./log/sdl/time.log
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

    echo "test on sdm time stop:" > ./log/sdm/time.log
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

    echo "test on sdn time stop:" > ./log/sdn/time.log
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

    
