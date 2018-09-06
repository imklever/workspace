#!/bin/env python
# -*- coding=utf-8 -*-

import time

def printBY(x):
    #print
    print '\033[30;43m'+x+'\033[0m'

def printFR(x):
    #print
    print '\033[31m'+x+'\033[0m'

printBY('转换功能:')
printFR('string --> timeStamp:')
printFR('string           --> time.struct_time')
printFR('time.struct_time --> timeStamp')
print
printFR('timeStamp --> string:')
printFR('timeStamp        --> time.struct_time')
printFR('time.struct_time --> string')

printBY('time.tzname')
print type(time.tzname)
print time.tzname

printBY('time.timezone:')
print type(time.timezone)
print time.timezone

printBY('time.altzone:')
print type(time.altzone)
print time.altzone

printBY('time.daylight:')
print type(time.daylight)
print time.daylight

timeStamp       = time.time()
gmTime          = time.gmtime(timeStamp)
localTime       = time.localtime(timeStamp)
ascTime         = time.asctime(localTime)
cTime           = time.ctime(timeStamp)
mkTime          = time.mktime(localTime)
strfTime_gm     = time.strftime('%Y-%m-%d %H:%M:%S', gmTime)
strfTime_local  = time.strftime('%Y-%m-%d %H:%M:%S', localTime)
strpTime_gm     = time.strptime(strfTime_gm,'%Y-%m-%d %H:%M:%S')
strpTime_local  = time.strptime(strfTime_local,'%Y-%m-%d %H:%M:%S')
strpTime_asc    = time.strptime(strfTime_local,'%Y-%m-%d %H:%M:%S')

printBY('timeStamp')
print type(timeStamp)
print timeStamp

#printBY ('time.clock():')
#print time.clock()

printBY('gmTime <-- timeStamp')
print type(gmTime)
print gmTime

printBY('localTime <-- timeStamp')
print type(localTime)
print localTime


printBY('ascTime <-- localTime')
print type(ascTime)
print ascTime

printBY('cTime <-- timeStamp')
print type(time.ctime(time.time()))
print time.ctime(time.time())

printBY('mktime <-- localTime')
print type(mkTime)
print mkTime


printBY('strfTime_gm <-- gmTime')
print type(strfTime_gm)
print strfTime_gm

printBY('strfTime_local <-- localTime')
print type(strfTime_local)
print strfTime_local


printBY('strpTime_gm <-- strfTime_gm')
print type(strpTime_gm)
print strpTime_gm

printBY('strpTime_local <-- strfTime_local')
print type(strpTime_local)
print strpTime_local


#print time.tzset()

printBY("strptime <-- ascTime")
print type(strpTime_asc)
print strpTime_asc

