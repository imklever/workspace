#!/bin/bash
rm -rf log
fio ./fio.config >> log 2>>log
