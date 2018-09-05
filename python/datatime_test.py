#!/bin/env python
# -*- coding=utf-8 -*-

from datetime import datetime
import time


#获取当前时间，精确到微秒
datetime_now=datetime.now()
strValue=str(datetime_now)
print ""
print "获取当前时间,精确到微秒:"
print "type datetime.now(): "+str(type(datetime_now))
print "datetime.now(): "+str(datetime_now)
print "datetime.timetuple(): "+str(type(datetime_now.timetuple()))
print "datetime.timetuple(): "+str(datetime_now.timetuple())


#字符串 --> 时间戳
d = datetime.strptime(strValue, "%Y-%m-%d %H:%M:%S.%f")
#d = datetime.strptime(datetime_now, "%Y-%m-%d %H:%M:%S.%f")
t = d.timetuple()
i_timeStamp = int(time.mktime(t))
f_timeStamp = float(str(i_timeStamp) + str("%06d" % d.microsecond))/1000000
print d.tzinfo
print d.tzname()
print d.utcoffset()

#时间戳 --> 字符串
d = datetime.fromtimestamp(f_timeStamp)
str1 = d.strftime("%Y-%m-%d %H:%M:%S")
str1 = d.strftime("%Y-%m-%d %H:%M:%S.%f")

print ""
print "获取当前时间,精确到微秒:"
print "str(datetime.now()): "+strValue

print ""
print "字符串 --> 时间戳:"
print type(i_timeStamp)
print 'time.mktime: '+str(i_timeStamp)
print type(f_timeStamp)
print 'time.mktime: '+str(f_timeStamp)


print ""
print "时间戳 --> 字符串:"
print type(str1)
print 'datetime.fromtimestamp.strftime: '+str1

print ""
print type(d)
print 'datetime.strptime(): '+str(d)
