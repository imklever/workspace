#!/bin/bash

mkdir ./log_37
cd ./log_37
scp -r 10.240.220.37:/root/fio_test/log/* ./
cd ..

mkdir ./log_38
cd ./log_38
scp -r 10.240.220.38:/root/fio_test/log/* ./
cd ..

mkdir ./log_39
cd ./log_39
scp -r 10.240.220.39:/root/fio_test/log/* ./
cd ..
