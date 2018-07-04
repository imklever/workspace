#!/bin/bash

scp -r ./config 10.240.220.37:/root/fio_test
scp ./run.sh ./generate.sh 10.240.220.37:/root/fio_test
scp ./start.sh ./generate.sh 10.240.220.37:/root/fio_test
