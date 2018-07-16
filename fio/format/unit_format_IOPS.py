#!/bin/env python

import commands
import sys


def trans_number(input_number):

    number=input_number.strip()

    value = number

    if number.lower().endswith('k'):
        value = number[0:-1]
        value = float(value)*1000
        value = str(value)
    elif number.lower().endswith('m'):
        value = number[0:-1]
        value = float(value)*1000000
        value = str(value)
    elif number.lower().endswith('g'):
        value = number[0:-1]
        value = float(value)*1000000000
        value = str(value)

    return value

#print trans_number(10)

if 2 != len(sys.argv):
    print "unit_format_IOPS.py <number[with unit]>"
    exit(1)

print trans_number(sys.argv[1])
