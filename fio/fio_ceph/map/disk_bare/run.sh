#!/bin/bash

    trap '{ echo "Ctrl-C to quit." ; exit 1; }' INT

    _disk_list="rbd0"
    

    lsblk
    echo ""

    df -Th
    echo ""

    echo -e "Data on these disk will \033[31mlost\033[0m, do you want to continue?"
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

    echo "test on rbd0 time start:"
    echo $time_start_disk
    echo ""

    echo "test on rbd0 time start:" > ./log/rbd0/time.log
    echo "${time_start_disk}" >> ./log/rbd0/time.log
    echo "${timestamp_start_disk}" >> ./log/rbd0/time.log

    
    echo "./config/rbd0/fio_write_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/rbd0/fio_write_64k.log.time fio ./config/rbd0/fio_write_64k.config  >  ./log/rbd0/fio_write_64k.log
    echo "./config/rbd0/fio_read_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/rbd0/fio_read_64k.log.time fio ./config/rbd0/fio_read_64k.config  >  ./log/rbd0/fio_read_64k.log
    echo "./config/rbd0/fio_write_512k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/rbd0/fio_write_512k.log.time fio ./config/rbd0/fio_write_512k.config  >  ./log/rbd0/fio_write_512k.log
    echo "./config/rbd0/fio_read_512k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/rbd0/fio_read_512k.log.time fio ./config/rbd0/fio_read_512k.config  >  ./log/rbd0/fio_read_512k.log
    echo "./config/rbd0/fio_write_1m.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/rbd0/fio_write_1m.log.time fio ./config/rbd0/fio_write_1m.config  >  ./log/rbd0/fio_write_1m.log
    echo "./config/rbd0/fio_read_1m.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/rbd0/fio_read_1m.log.time fio ./config/rbd0/fio_read_1m.config  >  ./log/rbd0/fio_read_1m.log
    echo "./config/rbd0/fio_randwrite_04k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/rbd0/fio_randwrite_04k.log.time fio ./config/rbd0/fio_randwrite_04k.config  >  ./log/rbd0/fio_randwrite_04k.log
    echo "./config/rbd0/fio_randread_04k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/rbd0/fio_randread_04k.log.time fio ./config/rbd0/fio_randread_04k.config  >  ./log/rbd0/fio_randread_04k.log
    echo "./config/rbd0/fio_randwrite_08k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/rbd0/fio_randwrite_08k.log.time fio ./config/rbd0/fio_randwrite_08k.config  >  ./log/rbd0/fio_randwrite_08k.log
    echo "./config/rbd0/fio_randread_08k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/rbd0/fio_randread_08k.log.time fio ./config/rbd0/fio_randread_08k.config  >  ./log/rbd0/fio_randread_08k.log
    echo "./config/rbd0/fio_randwrite_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/rbd0/fio_randwrite_64k.log.time fio ./config/rbd0/fio_randwrite_64k.config  >  ./log/rbd0/fio_randwrite_64k.log
    echo "./config/rbd0/fio_randread_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/rbd0/fio_randread_64k.log.time fio ./config/rbd0/fio_randread_64k.config  >  ./log/rbd0/fio_randread_64k.log


    time_stop_disk="$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H)-$(date +%M)-$(date +%S)"
    timestamp_stop_disk="$(date +%s)"

    echo ""
    echo "test on rbd0 time stop:"
    echo $time_stop_disk
    echo ""

    echo "" >> ./log/rbd0/time.log
    echo "test on rbd0 time stop:" >> ./log/rbd0/time.log
    echo "${time_stop_disk}" >> ./log/rbd0/time.log
    echo "${timestamp_stop_disk}" >> ./log/rbd0/time.log
    echo "" >> ./log/rbd0/time.log

    sec=$(echo "scale=4;${timestamp_stop_disk}-${timestamp_start_disk}" | bc )
    min=$(echo "scale=4;${sec}/60" | bc )
    hour=$(echo "scale=4;${min}/60" | bc )

    echo "time elapse:"
    echo "${sec}(s)"
    echo "${min}(m)"
    echo "${hour}(h)"

    echo "time elapse:" >> ./log/rbd0/time.log
    echo "${sec}(s)" >> ./log/rbd0/time.log
    echo "${min}(m)" >> ./log/rbd0/time.log
    echo "${hour}(h)" >> ./log/rbd0/time.log

    
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

    
