#!/bin/bash

mkdir ./ceph_log
cd ./ceph_log
scp -r 10.240.220.37:/root/fio_test/log/* ./
cd ..

