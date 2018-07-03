#!/bin/env python
# -*- coding: UTF-8 -*-
import re


test_imgae=["rbd_image0"]
test_rw=["read", "write"]
log_file="log"



f = open(log_file, "r")



rwflag=0

for line in f.readlines():
    for image in test_imgae:
        if(re.match(image, line)):
            print line
            break
    if rwflag > 0 and rwflag <= 4:
        rwflag+=1
        continue
    elif rwflag > 4 and rwflag <= 9:
        rwflag+=1
        date_tmp = line.strip().split('|')[1].split(',')
        print date_tmp
        if()
        data_len = len(date_tmp)
        for i in range(0,4):
            print i
            print date_tmp[i].strip()

        #key=
        #data[key]=value
        continue
    else:
        rwflag=0
        for rw in test_rw:
            if(re.match(rw, line.strip())):
                rwflag=1
                data={}
                print line
                print "image: ",image
                print "rw: ",rw
        continue








f.close()
