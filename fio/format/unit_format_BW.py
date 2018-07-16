#!/bin/env python

import commands
import sys


def trans_number(input_number):

    number=input_number.strip()

    value = number

    if number.lower().endswith('kib/s'):
        value = number[0:-5]
        value = float(value)/1000
        value = str(value)
    if number.lower().endswith('mib/s'):
        value = number[0:-5]
        value = float(value)*1
        value = str(value)
    elif number.lower().endswith('gib/s'):
        value = number[0:-5]
        value = float(value)*1000
        value = str(value)

    return value

#print trans_number(10)

if 2 != len(sys.argv):
    print "unit_format_BW.py <number[with unit]>"
    exit(1)

print trans_number(sys.argv[1])
