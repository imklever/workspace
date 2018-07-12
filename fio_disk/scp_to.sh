#!/bin/bash

scp -rp ./config 10.240.220.37:/root/fio_test
scp -p ./run.sh ./generate.sh parted.sh 10.240.220.37:/root/fio_test
