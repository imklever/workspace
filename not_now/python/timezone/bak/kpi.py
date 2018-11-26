# -*- coding: utf-8 -*-

import datetime
import time
from zabbix_client import ZabbixClientError
from storagemgmt.openstack.common import log
from storagemgmt.common.timeutil import LocalTimezone, to_unix_timestamp

LOG = log.getLogger(__name__)

class KPI(object):
    def __init__(self, allMap, kpiMap, itemName, **kwargs):
        LOG.info('Create KPI item: %s' % kwargs)
        kpi = kwargs['kpi']
        if kpi == 'all':
            self._keys_map = self.__build_keys_map(kpiMap, itemName)
        else:
            if itemName:
                self._key = allMap[kpi].format(itemName)
            else:
                self._key = allMap[kpi]
            
        self._hostId = kwargs['hostid']
        self._kpi = kwargs['kpi']
        if kwargs.has_key('granularity'):
            self._timeFrom = to_unix_timestamp(kwargs['time_from'])
            self._timeTill = to_unix_timestamp(kwargs['time_till'])
            self._granularity = kwargs['granularity']

    def __build_keys_map(self, kpiMap, itemName):
        '''
        {kpi1 : key1, kpi2: key2}
        '''
        keys = dict() 
        if itemName:
            for i in kpiMap:
                keys[i] = kpiMap[i].format(itemName)
        else:
            for i in kpiMap:
                keys[i] = kpiMap[i]
        return keys
            
    def get_zabbix_item_key(self):
        return self._key

    def get_zabbix_item(self, zabbixClient):
        output = ['itemid', 'key_', 'value_type', 'delay', 'lastvalue', 'lastclock', 'units']
        params = {'output' : output,
                  'hostids': self._hostId,
                  'search' : {'key_': self._key}
                 }
        LOG.info('zabbix item params: %s' % params)
        itemList = zabbixClient.call('item.get', params)
        if itemList:
            return itemList[0]
        return None

    def get_zabbix_history(self, zabbixClient):
        params = {'output'   : 'extend',
                  'itemids'  : self._itemId,
                  'history'  : self._valueType,
                  'sortfield': 'clock',
                  'sortorder': 'ASC',
                  'time_from': self._timeFrom,
                  'time_till': self._timeTill
                  }
        LOG.info('zabbix item history params: %s' % params)
        history = zabbixClient.call('history.get', params)
        return history

    def get_zabbix_trend(self, zabbixClient):
        params = {'output': ['itemid', 'clock', 'value_avg'],
                  'sortfield': 'clock',
                  'sortorder': 'ASC',
                  'itemids'  : self._itemId,
                  'time_from': self._timeFrom,
                  'time_till': self._timeTill
                  }
        LOG.info('zabbix item trend params: %s' % params)
        trend = zabbixClient.call('trend.get', params)
        return trend
        
    def get_latest_value(self, zabbixClient):
        current = time.time()
        item = self.get_zabbix_item(zabbixClient)
        if item:
            self._itemId = item['itemid']
            self._valueType = item['value_type']
            return self.resolve_latest_value(item, current)
        return ""

    def resolve_latest_value(self, item, current):
        delta = current - float(item['lastclock'])
        LOG.info('zabbix item latest value delta time: %s, %s' % (item['key_'], delta))
        if abs(delta) <= float(item['delay'])+10:
            return "{0}{1}".format(item['lastvalue'], item['units'])
        return ""

    def get_all_latest_data(self, zabbixClient):
        result = []
        for i in self._keys_map:
            self._key = self._keys_map[i]
            item = self.get_zabbix_item(zabbixClient)
            if item:
                time = self.__convert_to_datetime(int(item['lastclock'])), 
                result.append({'kpi'  : i, 
                               'time' : time[0], 
                               'value': item['lastvalue'], 
                               'unit' : item['units']})
        return result
            
    #def get_monitor_data(self, zabbixClient):
    #    item = self.get_zabbix_item(zabbixClient)
    #    if item:
    #        self._itemId = item['itemid']
    #        self._valueType = item['value_type']
    #        if self._granularity == 'realtime':
    #            history = self.get_zabbix_history(zabbixClient)
    #            LOG.info('leo_result5: %s' % history)
    #            result  = self.__convert_history(history)
    #            return {self._kpi : result}
    #        else :
    #            trend = self.get_zabbix_trend(zabbixClient)
    #            result = self.__convert_trend(trend)
    #            return {self._kpi : result}
    #    return "Error: Failed to get zabbix item id"

    def get_monitor_data(self, zabbixClient, time_zone_offset):
        item = self.get_zabbix_item(zabbixClient)
        if item:
            self._itemId = item['itemid']
            self._valueType = item['value_type']
            if self._granularity == 'realtime':
                history = self.get_zabbix_history(zabbixClient)
                LOG.info('leo_result5: %s' % history)
                result  = self.__convert_history(history,time_zone_offset)
                return {self._kpi : result}
            else :
                trend = self.get_zabbix_trend(zabbixClient)
                result = self.__convert_trend(trend, time_zone_offset)
                return {self._kpi : result}
        return "Error: Failed to get zabbix item id"

    #def __convert_history(self, historyData):
    #    result = []
    #    for history in historyData:
    #        timestamp = int(history['clock'])
    #        currTime = self.__convert_to_datetime(timestamp)
    #        result.append({'time': currTime, 'value': history['value'], 'timestamp': timestamp})
    #    return result

    #def __convert_history(self, historyData):
    #    result = []
    #    for history in historyData:
    #        timestamp = int(history['clock'])
    #        #currTime = self.__convert_to_datetime(timestamp)
    #        result.append({'value': history['value'], 'timestamp': timestamp})
    #    return result

    def __convert_history(self, historyData, time_zone_offset):
        result = []
        for history in historyData:
            timestamp = int(history['clock'])
            currTime = self.__convert_to_datetime(timestamp, time_zone_offset)
            result.append({'time': currTime, 'value': history['value'], 'timestamp': timestamp})
        return result

    def __convert_trend(self, trendData):
        result = []
        for trend in trendData:
            timestamp = int(trend['clock'])
            currTime = self.__convert_to_datetime(timestamp)
            result.append({'time': currTime, 'value': trend['value_avg'], 'timestamp': timestamp})
        return result
    
    #def __convert_to_datetime(self, timestamp):
    #    return datetime.datetime.fromtimestamp(timestamp, tz=LocalTimezone()) \
    #                    .strftime('%Y-%m-%d %H:%M:%S')

    def __convert_to_datetime(self, timestamp, time_zone_offset):
        LOG.info('leo_parameter_type: %s' % type(time_zone_offset))
        LOG.info('leo_parameter: %s' % time_zone_offset)
        LOG.info('leo_datatime: %s' % datetime.datetime.fromtimestamp(timestamp, tz=LocalTimezone()).strftime('%Y-%m-%d %H:%M:%S'))
        LOG.info('leo_datatime: %s' % datetime.datetime.fromtimestamp(timestamp, tz=LocalTimezone()).strftime('%Y-%m-%d %H:%M:%S'))
        return time.gmtime(timestamp+time_zone_offset*3600)
