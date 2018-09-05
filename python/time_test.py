#!/bin/env python
# -*- coding=utf-8 -*-

import time

#fun = lambda x: print('\033[1;31;43'+x+'\033[0m')
def printc(x):
    print
    print '\033[30;43m'+x+'\033[0m'

printc('time.timezone:')
print time.timezone

printc('time.altzone:')
print time.altzone

printc('time.daylight:')
print time.daylight

printc('time.time():')
print time.time()

#printc ('time.clock():')
#print time.clock()

printc('time.gmtime():')
print time.gmtime()

printc('time.localtime():')
print time.localtime()

printc('time.asctime(time.localtime()):')
print time.asctime(time.localtime())

printc('time.ctime(1536139066.9)')
print time.ctime(1536139066.9)

#printc ('time.mktime(time.gmtime())')
#print time.mktime(time.gmtime())
printc('time.mktime(time.localtime())')
print time.mktime(time.localtime())

#printc('time.strftime(time.gmtime())')
#print time.strftime('%Y-%m-%d %H:%M:%S', time.gmtime())
printc('time.strftime(time.localtime())')
print time.strftime('%Y-%m-%d %H:%M:%S', time.localtime())

printc("time.strptime('2018-09-05 05:19:59','%Y-%m-%d %H:%M:%S')")
print time.strptime('2018-09-05 05:19:59','%Y-%m-%d %H:%M:%S')
#print time.tzset()

printc("time.strptime('time.asctime(time.localtime())','%a %b %d %H:%M:%S %Y')")
print time.strptime(time.asctime(time.localtime()),'%a %b %d %H:%M:%S %Y')
