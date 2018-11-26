#!/bin/bash

username="root"
host_list="10.240.220.37"
for host in $host_list
do
    scp -p ./install.sh ./generate.sh ./create_iamge.sh ./delete_pool.sh ./parted.sh ${username}@${host}:/root/fio_test
done
