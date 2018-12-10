# -*- coding: utf-8 -*-
__author__ = 'lyj'

import time
from datetime import datetime, timedelta, tzinfo
from dateutil import tz

ZERO_TIME_DELTA = timedelta(0)
LOCAL_TIME_DELTA = timedelta(hours=8)  # 本地时区偏差


class UTC(tzinfo):
    def utcoffset(self, dt):
        return ZERO_TIME_DELTA

    def dst(self, dt):
        return ZERO_TIME_DELTA


class LocalTimezone(tzinfo):
    """
    Beijing Local Time Zone
    """

    def utcoffset(self, dt):
        return LOCAL_TIME_DELTA

    def dst(self, dt):
        return ZERO_TIME_DELTA

    def tzname(self, dt):
        return '+08:00'


def to_unix_timestamp(datetime):
    """
    transfer formated datetime string to unix timestamp
    :param datetime: %Y-%m-%d %H:%M:%S (e.g, 2016-12-06 18:00:47)
    :return:
    """
    s = time.mktime(time.strptime(datetime, '%Y-%m-%d %H:%M:%S'))
    return int(s)

def utc_to_local(utc_standard_time):
    from_zone = tz.tzutc()
    to_zone = tz.tzlocal()
    utc = utc_standard_time.replace(tzinfo=from_zone)
    central = utc.astimezone(to_zone)
    return central