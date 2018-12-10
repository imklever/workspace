#!/bin/bash

mkdir log_37
mkdir log_38
scp -r 10.240.220.37:/root/fio_test/log/* ./log_37
scp -r 10.240.220.38:/root/fio_test/log/* ./log_38
