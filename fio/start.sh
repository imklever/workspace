#!/bin/bash

if [ -f start.log ];then
    rm -f start.log
fi
time ./run.sh >> run.log 2>>run.log
