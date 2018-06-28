#!/bin/env python
# -*- coding=utf-8 -*-

import sys


def usage():
    print 'usage:\ncommand <filename>'


if len(sys.argv) < 2:
    usage()
    exit()

print 'hello'
fp = open(sys.argv[1])

class_struct={}
var_tmp=""

#读每一行
for line in fp.readlines():

    l=line.strip()

    #analyse line
    word=""
    for c in l:
        if c == ' ' or c == '\t' or c == '\n':
            if len(word) == 0
            word=""
                continue
            if world.lower() == 'stunct'
            word=""
        else:
            word = word+c
    

