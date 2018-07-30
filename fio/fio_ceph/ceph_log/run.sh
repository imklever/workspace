#!/bin/bash

    trap '{ echo "Ctrl-C to quit." ; exit 1; }' INT

    _disk_list=""
    

    lsblk
    echo ""

    df -Th
    echo ""

    ceph -s
    echo ""



    echo -e "\033[47;31m"
    echo -e "make sure the ceph cluster is health"
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

    
    echo "./config/fio_write_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/fio_write_64k.log.time fio ./config/fio_write_64k.config  >  ./log/fio_write_64k.log
    echo "./config/fio_read_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/fio_read_64k.log.time fio ./config/fio_read_64k.config  >  ./log/fio_read_64k.log
    echo "./config/fio_write_512k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/fio_write_512k.log.time fio ./config/fio_write_512k.config  >  ./log/fio_write_512k.log
    echo "./config/fio_read_512k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/fio_read_512k.log.time fio ./config/fio_read_512k.config  >  ./log/fio_read_512k.log
    echo "./config/fio_write_1m.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/fio_write_1m.log.time fio ./config/fio_write_1m.config  >  ./log/fio_write_1m.log
    echo "./config/fio_read_1m.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/fio_read_1m.log.time fio ./config/fio_read_1m.config  >  ./log/fio_read_1m.log
    echo "./config/fio_randwrite_04k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/fio_randwrite_04k.log.time fio ./config/fio_randwrite_04k.config  >  ./log/fio_randwrite_04k.log
    echo "./config/fio_randread_04k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/fio_randread_04k.log.time fio ./config/fio_randread_04k.config  >  ./log/fio_randread_04k.log
    echo "./config/fio_randwrite_08k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/fio_randwrite_08k.log.time fio ./config/fio_randwrite_08k.config  >  ./log/fio_randwrite_08k.log
    echo "./config/fio_randread_08k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/fio_randread_08k.log.time fio ./config/fio_randread_08k.config  >  ./log/fio_randread_08k.log
    echo "./config/fio_randwrite_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/fio_randwrite_64k.log.time fio ./config/fio_randwrite_64k.config  >  ./log/fio_randwrite_64k.log
    echo "./config/fio_randread_64k.config"
    /usr/bin/time -f "time:%E\nuser:%U\nsys:%S" -o ./log/fio_randread_64k.log.time fio ./config/fio_randread_64k.config  >  ./log/fio_randread_64k.log
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

    
