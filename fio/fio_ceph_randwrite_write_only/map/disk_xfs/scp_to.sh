#!/bin/bash

scp -p ../install.sh ../check_disk_info.sh ./generate.sh parted.sh 10.240.220.37:/root/fio_test
scp -p ../install.sh ../check_disk_info.sh ./generate.sh parted.sh 10.240.220.38:/root/fio_test
scp -p ../install.sh ../check_disk_info.sh ./generate.sh parted.sh 10.240.220.39:/root/fio_test
