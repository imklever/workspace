"""
zabbix client to connect to zabbix server, and send zabbix api
"""
import re
import datetime
import json
import multiprocessing
from zabbix_client import ZabbixClientError
from storagemgmt.openstack.common import log
from zabbix_client import ZabbixServerProxy
from storagemgmt.common.timeutil import LocalTimezone, to_unix_timestamp
from storagemgmt.common.kpifactory import KPIFactory
from functools import wraps

import logging
logging.getLogger('zabbix_client.api_wrapper').setLevel(logging.WARNING)


LOG = log.getLogger(__name__)


def zab_singleton(cls):
    instances = {}

    def _singleton(*args, **kw):
        if len(args) == 0 or args[0] is None:
            raise Exception("A zabbix server ip must be supplied.")

        zabbix_server = args[0]

        if zabbix_server not in instances:
            instances[zabbix_server] = cls(*args, **kw)
        return instances[zabbix_server]

    return _singleton


def pre_call(func):
    @wraps(func)
    def wrapper(self, *args, **kwargs):
        LOG.debug("Calling %s ..." % func.__name__)
        if not self.client:
            self.get_client()
        return func(self, *args, **kwargs)

    return wrapper


@zab_singleton
class ZabbixClient(object):
    groupName = "cloudCeph"
    userTag = '@@user@@'
    templateNames = ["Template SDS Ceph Cluster",
                     "Template SDS Ceph Pool",
                     "Template SDS Ceph RBD",
                     "Template SDS Disk Linux",
                     "Template SDS Host Linux"]
    cephtemplates = ["Template SDS Ceph Cluster",
                     "Template SDS Ceph Pool"]
    rbdtemplates = ["Template SDS Ceph RBD"]
    hosttemplates = ["Template SDS Disk Linux",
                     "Template SDS Host Linux"]

    template_ids = []
    cephtemplate_ids = []
    rbdtemplate_ids = []
    hosttemplate_ids = []
    mailtypeid = None # email media type id
    type_list = ('cpu', 'mem', 'cluster_io', 'disk_io', 'net')
    zab_lock = multiprocessing.Lock()

    def __init__(self, zabbix_server, user, password):
        LOG.info("Initializing zabbix client ...")
        self.zabbix_server = zabbix_server
        self.user = user
        self.password = password
        self.client = None
        if not self.zabbix_server:
            LOG.error('No zabbix server ip supplied!')
        else:
            try:
                self.client = ZabbixServerProxy('http://%s/zabbix' % self.zabbix_server)
                token = self.client.user.login(user=self.user, password=self.password)
            except Exception as e:
                LOG.error("Get zabbix server connection failed. Caused by %s" % e.message)
                raise Exception("Get zabbix server connection failed. Caused by %s" % e.message)

    def get_client(self):
        if not self.client:
            try:
                self.client = ZabbixServerProxy('http://%s/zabbix' % self.zabbix_server)
                token = self.client.user.login(user=self.user, password=self.password)
            except ZabbixClientError as e:
                LOG.error("Get zabbix server connection failed. Caused by %s" % e.message)
                raise Exception("Get zabbix server connection failed. Caused by %s" % e.message)

        return self.client
    
    def set_interval(self, interval=30):
        self.interval = interval

    @pre_call
    def has_configured(self):
        try:
            if not self.host_group_exists():
                group = self.create_host_group()
            else:
                group = True
            if not self.has_templates():
                template = self.import_templates()
            else:
                template = True
            self.config_notification_actions()
            if group and template:
               return True
            return False
        except Exception as e:
            LOG.error("Calling has_configured failed. Caused by %s" % e.message)
            return False

    @pre_call
    def host_group_exists(self):
        if self.client:
            if self.client.hostgroup.get(output='extend', filter={'name':self.groupName}):
                LOG.info("Host group: %s exists" % self.groupName)
                return True
            else:
                LOG.info("Host group: %s does not exist" % self.groupName)
        return False

    @pre_call
    def create_host_group(self):
        if self.client:
            if not self.host_group_exists():
                try:
                    hostid = self.client.hostgroup.create(name=self.groupName)
                    return hostid
                except ZabbixClientError as e:
                    LOG.error("Create host group failed. Caused by %s" % e.message)
        return False

    @pre_call
    def get_host_group(self):
        group = None
        if self.client:
            filter = dict(name=[self.groupName])
            try:
                group = self.client.hostgroup.get(output='extend', filter=filter)
            except ZabbixClientError as e:
                LOG.error("Get host group failed. Caused by %s" % e.message)
        return group

    @pre_call
    def import_templates(self):
        templateFileNames = ("Template_SDS_Ceph_Cluster.xml",
                             "Template_SDS_Ceph_Pool.xml",
                             "Template_SDS_Ceph_RBD.xml",
                             "Template_SDS_Disk_Linux.xml",
                             "Template_SDS_Host_Linux.xml")
        filePath = "/etc/storagemgmt/template/"
        policy = { "createMissing": 'true', "updateExisting": 'true', "deleteMissing": 'true'}
        params= {
            "format": "xml",
            "rules": {
                "applications": policy,
                "discoveryRules": policy,
                "groups": policy,
                "hosts": policy,
                "templates": policy,
                "items": policy,
                "triggers": policy
             }
         }
        if self.client:
            with self.zab_lock:
                for template in templateFileNames:
                    templateFile = filePath + template
                    with open(templateFile) as f:
                        content = f.read()
                        #if hasattr(self, 'interval'):
                        #    content = self.update_interval(content)
                        params['source'] = content
                        try:
                            result = self.client.call('configuration.import', params)
                            if not result:
                                LOG.error("Import template %s failed. Server return False" % template)
                                return False
                        except ZabbixClientError as e:
                            LOG.error("Import template %s failed. Caused by %s" % (template, e.message))
                            return False
                return self.has_templates()
        return False
    
    @pre_call
    def update_interval(self, template_content):
        LOG.info("replace zabbix interval to {}".format(self.interval))
        #only replace less then 100, otherwise, discovery interval also be changed
        pattern = r'<delay>\d\d</delay>'
        strinfo = re.compile(pattern)
        target = r'<delay>{}</delay>'.format(self.interval)
        return strinfo.sub(target, template_content)

    @pre_call
    def has_templates(self):
        tmp_templates = []
        if self.client:
            try:
                params = {'output': ['host', 'status', 'templateid'],
                          'filter': {'host': self.cephtemplates}
                          }
                templates = self.client.call('template.get', params)
                self.cephtemplate_ids = [dict(templateid=template['templateid']) for template in templates]

                params = {'output': ['host', 'status', 'templateid'],
                          'filter': {'host': self.rbdtemplates}
                          }
                templates = self.client.call('template.get', params)
                self.rbdtemplate_ids = [dict(templateid=template['templateid']) for template in templates]

                params = {'output': ['host', 'status', 'templateid'],
                          'filter': {'host': self.hosttemplates}
                          }
                templates = self.client.call('template.get', params)
                self.hosttemplate_ids = [dict(templateid=template['templateid']) for template in templates]
                tmp_templates = self.cephtemplate_ids + self.rbdtemplate_ids + self.hosttemplate_ids
                self.template_ids = tmp_templates
            except ZabbixClientError as e:
                LOG.error("Get cluster templates failed. Caused by %s" % e.message)
            if len(self.templateNames) == len(tmp_templates):
                return True
        return False

    @pre_call
    def check_template_id(self):
        if len(self.templateNames) == len(self.template_ids):
            return True
        return self.has_templates()

    @pre_call
    def add_host(self, ceph_server_id, ceph_server_ip, kpi_status="enable"):
        LOG.info("ceph_server_id: %s , ceph_server_ip: %s" % (ceph_server_id, ceph_server_ip))
        carry = dict()
        if self.client:
            try:
                exists = self.host_exists(ceph_server_ip)
                if not exists:
                    interface = dict()
                    interface['type'] = 1
                    interface['main'] = 1
                    interface['useip'] = 1
                    interface['ip'] = ceph_server_ip
                    interface['dns'] = ""
                    interface['port'] = "10050"

                    group = self.get_host_group()
                    if group and len(group) > 0:
                        group_id = group[0]['groupid']
                        carry['host'] = ceph_server_ip
                        carry['interfaces'] = [interface]
                        carry['groups'] = [dict(groupid=group_id)]
                        if kpi_status == 'disable':
                            carry['templates'] = []
                        else:
                            carry['templates'] = self.hosttemplate_ids

                        host_ids = self.client.call('host.create', carry)
                        if host_ids and len(host_ids) > 0:
                            LOG.info("Add host successfully. host_id: %s" % host_ids['hostids'][0])
                            return host_ids['hostids'][0]
                else:
                    params = {
                        'output': 'extend',
                        'filter': {
                            'host': ceph_server_ip
                        }
                    }
                    hosts = self.client.call('host.get', params)
                    if hosts and len(hosts) > 0:
                        LOG.info("Add host successfully. host_id: %s" % hosts[0]['hostid'])
                        return hosts[0]['hostid']
            except ZabbixClientError as e:
                LOG.error("Add host failed. Caused by %s" % e.message)

        return None

    @pre_call
    def add_ceph_host(self, host_name, ceph_agent_ip, kpi_status="enable"):
        LOG.info("ceph_host_name: %s , ceph_agent_ip: %s" % (host_name, ceph_agent_ip))
        carry = dict()
        if self.client:
            try:
                exists = self.host_exists(host_name)
                if not exists:
                    interface = dict()
                    interface['type'] = 1
                    interface['main'] = 1
                    interface['useip'] = 1
                    interface['ip'] = ceph_agent_ip
                    interface['dns'] = ""
                    interface['port'] = "10050"

                    group = self.get_host_group()
                    if group and len(group) > 0:
                        group_id = group[0]['groupid']
                        carry['host'] = host_name
                        carry['interfaces'] = [interface]
                        carry['groups'] = [dict(groupid=group_id)]
                        if kpi_status == 'disable':
                            carry['templates'] = []
                        else:
                            carry['templates'] = self.cephtemplate_ids

                        host_ids = self.client.call('host.create', carry)
                        if host_ids and len(host_ids) > 0:
                            LOG.info("Add host successfully. host_id: %s" % host_ids['hostids'][0])
                            return host_ids['hostids'][0]
                else:
                    params = {
                        'output': 'extend',
                        'filter': {
                            'host': host_name
                        }
                    }
                    hosts = self.client.call('host.get', params)
                    if hosts and len(hosts) > 0:
                        LOG.info("Add Ceph Cluster host successfully. host_id: %s" % hosts[0]['hostid'])
                        return hosts[0]['hostid']
            except ZabbixClientError as e:
                LOG.error("Add Ceph Cluster host failed. Caused by %s" % e.message)

        return None

    @pre_call
    def add_rbd_hosts(self, cluster_name, rbd_agent_ip, kpi_status="enable"):
        LOG.info("rbd_cluster_name: %s , rbd_agent_ip: %s" % (cluster_name, rbd_agent_ip))
        if not self.client:
            return None
        try:
            result = dict()
            port = 10061
            interface = dict()
            interface['type'] = 1
            interface['main'] = 1
            interface['useip'] = 1
            interface['ip'] = rbd_agent_ip
            interface['dns'] = ""
            group = self.get_host_group()
            if not group:
                return None
            group_id = group[0]['groupid']
            for i in range(3):
                rbd_host = "{0}{1}{2}".format(cluster_name, "rbd", i+1)
                exists = self.host_exists(rbd_host)
                if exists:
                    params = {
                        'output': 'extend',
                        'filter': {
                            'host': rbd_host
                        }
                    }
                    hosts = self.client.call('host.get', params)
                    if hosts and len(hosts) > 0:
                        result[i+1] = [rbd_host, port+i, hosts[0]['hostid']]
                        continue
                    else:
                        return None

                interface['port'] = str(port+i)
                carry = dict()
                carry['host'] = rbd_host
                carry['interfaces'] = [interface]
                carry['groups'] = [dict(groupid=group_id)]
                if kpi_status == 'disable':
                    carry['templates'] = []
                else:
                    carry['templates'] = self.rbdtemplate_ids

                host_ids = self.client.call('host.create', carry)
                if not host_ids:
                    return None
                result[i+1] = [rbd_host, port+i, host_ids['hostids'][0]]

            LOG.info("Add RBD hosts successfully: %s" % result)
            return result
        except ZabbixClientError as e:
            LOG.error("Add Ceph RBD hosts failed. Caused by %s" % e.message)
            return None

    @pre_call
    def update_ceph_host(self, zabbix_host_id, ceph_server_ip):
        LOG.info("update ceph host {} to : {} ".format(zabbix_host_id, ceph_server_ip))
        if self.client: 
            try:
                interface = dict()
                interface['type'] = 1
                interface['main'] = 1
                interface['useip'] = 1
                interface['ip'] = ceph_server_ip
                interface['dns'] = ""
                interface['port'] = "10050"
                params = {
                        'hostid': zabbix_host_id,
                        'interfaces': [interface]
                    }
                hosts = self.client.call('host.update', params)
                if hosts:
                    LOG.info("update ceph host ip successfully. host_id: %s" % zabbix_host_id)
                    return True
            except ZabbixClientError as e:
                LOG.error("update ceph host ip failed. Caused by %s" % e.message)
        return False
        
    @pre_call
    def update_rbd_hosts(self, rbd_hosts, rbd_agent_ip):
        LOG.info("update rbd hosts {} to : {} ".format(rbd_hosts, rbd_agent_ip))
        if not self.client: 
            return False
        try:
            for key, value in rbd_hosts.items():
                [host_name, port, host_id] = value
                params = {
                    'output': ['interfaceid'],
                    'filter': {'hostid': host_id}
                    }
                interfaces = self.client.call('hostinterface.get', params)
                if not interfaces:
                    return False
                if_id = interfaces[0]['interfaceid']
                params = {
                    'interfaceid': if_id,
                    'ip': rbd_agent_ip,
                    'port': port
                }
                update = self.client.call('hostinterface.update', params)
                if not update:
                    return False
            LOG.info("update RBD hosts successfully: %s" % rbd_hosts)
            return True
        except ZabbixClientError as e:
            LOG.error("update RBD hosts failed. Caused by %s" % e.message)
        return False

    @pre_call
    def link_host_template(self, zabbix_host_id):
        LOG.info("link zabbix host template : %s " % zabbix_host_id)
        if self.client and self.hosttemplate_ids:
            try:
                params = {
                        'hostid': zabbix_host_id,
                        'templates': self.hosttemplate_ids
                    }
                hosts = self.client.call('host.update', params)
                if hosts:
                    LOG.info("link host template successfully. host_id: %s" % zabbix_host_id)
                    return True
            except ZabbixClientError as e:
                LOG.error("link host template failed. Caused by %s" % e.message)
        return False

    @pre_call
    def unlink_host_template(self, zabbix_host_id):
        LOG.info("unlink zabbix host template : %s " % zabbix_host_id)
        if self.client and self.hosttemplate_ids:
            try:
                params = {
                        'hostid': zabbix_host_id,
                        'templates_clear': self.hosttemplate_ids
                    }
                hosts = self.client.call('host.update', params)
                if hosts:
                    LOG.info("unlink zabbix host template successfully. host_id: %s" % zabbix_host_id)
                    return True
            except ZabbixClientError as e:
                LOG.error("unlink zabbix host template failed. Caused by %s" % e.message)
        return False

    @pre_call
    def link_ceph_template(self, zabbix_host_id):
        LOG.info("link zabbix ceph template : %s " % zabbix_host_id)
        if self.client and self.cephtemplate_ids:
            try:
                params = {
                        'hostid': zabbix_host_id,
                        'templates': self.cephtemplate_ids
                    }
                hosts = self.client.call('host.update', params)
                if hosts:
                    LOG.info("link ceph template successfully. host_id: %s" % zabbix_host_id)
                    return True
            except ZabbixClientError as e:
                LOG.error("link ceph template failed. Caused by %s" % e.message)
        return False

    @pre_call
    def unlink_ceph_template(self, zabbix_host_id):
        LOG.info("unlink zabbix ceph template : %s " % zabbix_host_id)
        if self.client and self.cephtemplate_ids :
            try:
                params = {
                        'hostid': zabbix_host_id,
                        'templates_clear': self.cephtemplate_ids
                    }
                hosts = self.client.call('host.update', params)
                if hosts:
                    LOG.info("unlink zabbix ceph template successfully. host_id: %s" % zabbix_host_id)
                    return True
            except ZabbixClientError as e:
                LOG.error("unlink zabbix ceph template failed. Caused by %s" % e.message)
        return False

    @pre_call
    def host_exists(self, ceph_server_ip):
        LOG.info("ceph_server_ip: %s" % ceph_server_ip)
        exists = self.client.host.get(output='extend', filter={'name':ceph_server_ip})
        if exists:
            LOG.info("Host : %s exists" % ceph_server_ip)
        else:
            LOG.info("Host : %s does not exist" % ceph_server_ip)
        return exists

    @pre_call
    def delete_host(self, zabbix_host_id, ceph_server_ip):
        if self.client:
            host_id = self.client.host.exists(host=ceph_server_ip)
            if host_id:
                params = [host_id]
                host_id_resp = self.client.host.delete(params)
                LOG.info("Delete host successfully. host_id_resp: %s" % host_id_resp)
            else:
                LOG.error("Host %s cannot be found" % ceph_server_ip)

    @pre_call
    def get_items(self, zabbix_host_id, type):
        items = []
        keys = []
        if self.client:
            params = {
                'output': ['itemid', 'key_'],
                'hostids': [zabbix_host_id],
            }

            if type == 'cpu':
                params.update({'search': {'key_': 'system.cpu.util[idle]'}})
                result = self.client.call('item.get', params)
            elif type == 'io':
                params.update({'search': {'key_': 'system.cpu.util[idle]'}})
                result = self.client.call('item.get', params)
            elif type == 'net':
                params.update({'search': {'key_': 'net.if'}})
                result = self.client.call('item.get', params)
                for item in result:
                    ifname = re.match(r'net\.if\.(in|out)\[(.+)\]', item['key_']).group(2)
                    tmp = {'id': item['itemid'], 'name': ifname}
                    if ifname not in keys:
                        keys.append(ifname)
                        items.append(tmp)
        LOG.debug("Retrieved items: %s" % items)
        return items

    #@pre_call
    #def get_kpi_history(self, targetInfo):
    #    LOG.info('get_kpi_history: %s' % targetInfo)
    #    if self.client:
    #        kpi = KPIFactory().create_kpi(**targetInfo)
    #        LOG.info('get_kpi_factory: %s' % kpi)
    #        data = kpi.get_monitor_data(self.client)
    #        #LOG.info('leo_result4: %s' % data)
    #        return data
    #    return "Error: Failed to get zabbix client"

    @pre_call
    def get_kpi_history(self, targetInfo,time_zone_offset):
        LOG.info('get_kpi_history: %s' % targetInfo)
        if self.client:
            kpi = KPIFactory().create_kpi(**targetInfo)
            LOG.info('get_kpi_factory: %s' % kpi)
            data = kpi.get_monitor_data(self.client, time_zone_offset)
            #LOG.info('leo_result4: %s' % data)
            return data
        return "Error: Failed to get zabbix client"

    @pre_call
    def get_target_latest_kpi(self, targetInfo):
        LOG.info('get_target_latest_kpi: %s' % targetInfo)
        if self.client:
            kpi = KPIFactory().create_kpi(**targetInfo)
            LOG.info('get_all_latest_data: %s' % kpi)
            data = kpi.get_all_latest_data(self.client)
            return data
        return []

    @pre_call
    def get_history(self, zabbix_host_id, item_type, item_name=None, sortfield='clock',
                    sortorder='ASC', time_from=None, time_till=None):
        LOG.debug('Params: zabbix_host_id=%s, item_type=%s, item_name=%s, time_from=%s, time_till=%s'
                 % (zabbix_host_id, item_type, item_name, time_from, time_till))

        histories = {}
        if self.client:
            LOG.debug('Prepared zabbix call parameters')
            history_params = {
                'output': 'extend',
                'history': 3,
                'sortfield': sortfield,
                'sortorder': sortorder,
                'limit': 50
            }
            time_from and history_params.update({'time_from': to_unix_timestamp(time_from)})
            time_till and history_params.update({'time_till': to_unix_timestamp(time_till)})

            params = {
                'output': ['itemid', 'key_', 'value_type'],
                'hostids': [zabbix_host_id],
            }

            items = []
            keys = []
            if item_type == 'cpu':
                params.update({'search': {'key_': 'system.cpu.util'}})
                result = self.client.call('item.get', params)
                for item in result:
                    matched = re.match(r'system\.cpu\.util\[,(.+)\]', item['key_'])
                    _type = matched.group(1)
                    # query history data
                    histories.update({_type: self.retrieve_history(item['itemid'], item['value_type'], history_params)})
            elif item_type == 'mem':
                params.update({'search': {'key_': 'vm.memory.size'}})
                result = self.client.call('item.get', params)
                for item in result:
                    matched = re.match(r'vm\.memory\.size\[(.+)\]', item['key_'])
                    _type = matched.group(1)
                    # query history data
                    histories.update({_type: self.retrieve_history(item['itemid'], item['value_type'], history_params)})
            elif item_type == 'cluster_io':
                io_obj = self.get_cluster_io_items(zabbix_host_id)
                item_id = io_obj['iopsOp']['item_id']
                histories.update({'iopsOp': self.retrieve_history(item_id, io_obj['iopsOp']['value_type'], history_params)})
                item_id = io_obj['iopsRead']['item_id']
                histories.update({'iopsRead': self.retrieve_history(item_id, io_obj['iopsRead']['value_type'], history_params)})
                item_id = io_obj['iopsWrite']['item_id']
                histories.update({'iopsWrite': self.retrieve_history(item_id, io_obj['iopsWrite']['value_type'], history_params)})
            elif item_type == 'disk_io':
                params.update({'search': {'key_': 'custom.vfs.dev.iostats.util[%s]' % item_name[0:3]}})
                result = self.client.call('item.get', params)
                if result and len(result) > 0:
                    item = result[0]
                    histories.update({'iopsUtil': self.retrieve_history(item['itemid'], item['value_type'], history_params)})
                params.update({'search': {'key_': 'custom.vfs.dev.iostats.await[%s]' % item_name[0:3]}})
                result = self.client.call('item.get', params)
                if result and len(result) > 0:
                    item = result[0]
                    histories.update({'iopsWait': self.retrieve_history(item['itemid'], item['value_type'], history_params)})
            elif item_type == 'net':
                params.update({'search': {'key_': 'net.if'}})
                result = self.client.call('item.get', params)
                if not item_name:
                    item_name = '(.+)'
                for item in result:
                    matched = re.match(r'net\.if\.(in|out)\[(%s)\]' % item_name, item['key_'])
                    if matched:
                        _type = matched.group(1)
                        # query history data
                        histories.update({_type: self.retrieve_history(item['itemid'], item['value_type'], history_params)})
            else:
                LOG.error('Unknown itme type: %s' % item_type)
                raise Exception('Unknown itme type: %s, possible valid types: %s' % (item_type, self.__class__.type_list))
        LOG.debug("Retrieved histories: %s" % histories)
        return histories

    def retrieve_history(self, item_id, value_type, history_params):
        history_params.update({'history': value_type})
        history_params.update({'itemids': item_id})
        query_result = self.client.call('history.get', history_params)
        hists = []
        for history in query_result:
            curr_time = datetime.datetime.fromtimestamp(int(history['clock']), tz=LocalTimezone()) \
                .strftime('%Y-%m-%d %H:%M:%S')
            hists.append({'time': curr_time, 'value': history['value']})
        return hists

    def get_cluster_io_items(self, zabbix_host_id):
        io_obj = {'iopsOp': '',
                  'iopsRead': '',
                  'iopsWrite': ''
                  }
        params = {
            'output': 'extend',
            'hostids': [zabbix_host_id],
            'search': {'key_': 'ceph.ops'}
        }
        result = self.client.call('item.get', params)
        if result and len(result) > 0:
            io_obj.update({
                'iopsOp': {
                    'item_id': result[0]['itemid'],
                    'value': result[0]['lastvalue'],
                    'value_type': result[0]['value_type']
                }
            })
        params.update({'search': {'key_': 'ceph.rdbps'}})
        result = self.client.call('item.get', params)
        if result and len(result) > 0:
            io_obj.update({
                'iopsRead': {
                    'item_id': result[0]['itemid'],
                    'value': result[0]['lastvalue'],
                    'value_type': result[0]['value_type']
                }
            })
        params.update({'search': {'key_': 'ceph.wrbps'}})
        result = self.client.call('item.get', params)
        if result and len(result) > 0:
            io_obj.update({
                'iopsWrite': {
                    'item_id': result[0]['itemid'],
                    'value': result[0]['lastvalue'],
                    'value_type': result[0]['value_type']
                }
            })
        return io_obj

    def retrieve_trigger_status(self, filters=None, groupid=None, use_last_change_value=False):
        '''
        :param filters:  filters like {'value':1, 'status':1}
        Note:
        value: 0 - (default) OK; 1 - Problem
        status: 0 - (default) enabled; 1 - disabled.
        :return:
            value (trigger value), datavalue (item value), status (enable/disabled)
        '''
        params = {
            'output': ['value', 'status', 'lastchange','expression', 'description','priority','state','comments'],
            'selectFunctions': 'extend',  # ['itemid','functionid','function','paramter'],
            'selectHosts': ['hostid', 'name'],
            'expandExpression': 1,
            'expandDescription': 1,
            'sortfield': 'triggerid'
        }
        if filters:
            params.update({'filter': filters})
        if groupid:
            params.update({'groupids': groupid})
        result = self.client.call("trigger.get", params)
        itemids = [i["functions"][0]["itemid"] for i in result]
        items = self.get_item(itemids)
        pair ={ i["itemid"]: [i["lastvalue"],i["key_"]] for i in items }
        for i in result:
            if use_last_change_value:
                historyparams = {
                    'history': 0,
                    'itemids': i["functions"][0]["itemid"],
                    'time_from': int(i['lastchange']),
                    'time_till': int(i['lastchange']),
                    'limit': 1
                }
                history = self.client.call('history.get', historyparams)
                if history:
                    i["datavalue"] = history[0]['value']
                else:
                    i["datavalue"] = "-1"
            else:
                i["datavalue"] = pair[i["functions"][0]["itemid"]][0]
            i["item_key"] = pair[i["functions"][0]["itemid"]][1]
            i["user_create"] = i['comments'] == self.userTag and 1 or 0
        LOG.debug("Retrieved %d trigger: for filter %s, result is: %s" % (len(result), str(filters), json.dumps(result, indent=1)))
        return result

    @pre_call
    def get_triggers_by_filter(self, filters=None):
        '''
        :param filters:  filters like {'value':1, 'status':1}
        :return:
        '''
        params = {
            'output': 'extend',
            'expandExpression': 1,
            'expandDescription': 1
        }
        if filters:
            params.update({'filter': filters})
        result = self.client.call("trigger.get", params)

        LOG.debug("Retrieved %d trigger: for filter %s, result is: %s" % (len(result), str(filters), json.dumps(result, indent=1)))
        return result

    @pre_call
    def get_triggers_by_items(self, itemids):
        '''
        :param filters:  filters like {'value':1, 'status':1}
        :return:
        '''
        params = {
            'output': 'extend',
            'expandExpression': 1,
            'expandDescription': 1,
            'itemids': itemids,
            'selectHosts': ['hostid', 'name'],
        }
        result = self.client.call("trigger.get", params)
        for i in result:
            i["user_create"] = i['comments'] == self.userTag and 1 or 0
        LOG.debug("Retrieved %d trigger: for itemids %s, result is: %s" % (len(result), str(itemids), json.dumps(result, indent=1)))
        return result

    @pre_call
    def get_trigger(self, trigger_ids):
        params = {
            'output': 'extend',
            # 'output': ['value','state','status','expression','description','functions', 'hosts'],
            'triggerids': trigger_ids,
            'selectFunctions': 'extend' , #['itemid'],
            'selectHosts':['hostid','name'],
            # 'expandExpression': 1
        }
        result = self.client.call('trigger.get', params)
        LOG.debug("Retrieved %d trigger %s: %s" % (len(result), str(trigger_ids), json.dumps(result, indent=1)))
        return result

    @pre_call
    def get_item(self, item_ids):
        params = {
            'output': ['item_id','key_','name','lastvalue'],
            'itemids': item_ids

        }
        result = self.client.call('item.get', params)
        LOG.debug("Retrieved %d item %s: %s" % (len(result), str(item_ids), json.dumps(result, indent=1)))
        return result

    @pre_call
    def get_items_by_search(self, search = None):
        params = {
            'output': ['item_id','key_','name','lastvalue'],
        }
        if search:
            params.update({'search': search})
        result = self.client.call('item.get', params)
        LOG.debug("Retrieved %d item by filter %s: %s" % (len(result), str(search), json.dumps(result, indent=1)))
        return result

    @pre_call
    def get_templated_triggers(self, filters = None):
        '''
        return only triggers that belong to the four templates we use
        :param filters:
        :return:
        '''
        hosts = self.client.host.get(output=['hostid','name'], search={'name': "Template SDS"},templated_hosts=1)

        hostids = [ i['hostid'] for i in hosts]
        print hostids
        params = {
            'output': ['triggerid', 'description', 'expression'],
            'expandExpression': 1,
            'hostids': hostids
        }
        self.client.call('trigger.get', params)
        if filter:
            params.update({'filter': filters})
        result = self.client.call('trigger.get',params)
        LOG.debug("Retrieved %d triggers. %s" % (len(result), json.dumps(result, indent=1)))
        return result

    @pre_call
    def create_trigger(self, params):
        '''
        :param value:
        required value keys to create a trigger:
            description, expression,
        other keys:
            priority(0 default not classified), status (0 default enabled)
        :return:
        '''
        result = None
        # let zabbix does all the check
        # if not ( params.has_key("description") and params.has_key("expression") ):
        #     raise Exception("Create trigger failed. Invalid Parameters")
        params['comments'] = self.userTag
        try:
            result = self.client.call('trigger.create', params)
            LOG.info("Created trigger: %s" % json.dumps(result, indent=1))
        except ZabbixClientError as e:
            LOG.error("Create trigger failed. Caused by %s" % e.message)
            raise Exception("Create trigger failed. Caused by %s" % e.message)
        return result

    @pre_call
    def update_trigger(self, params):
        '''
        :param params:
            update fields allowed: triggerid( required), status (0 default enabled/1), priority, expression
        :return:
        '''
        try:
            result = self.client.call('trigger.update', params)
            LOG.info("Update trigger: %s" % json.dumps(result, indent=1))
        except ZabbixClientError as e:
            LOG.error("Update trigger failed. Caused by %s" % e.message)
            raise Exception("Update trigger failed. Caused by %s" % e.message)
        return result

    @pre_call
    def delete_trigger(self, triggerids):
        '''
        :param params:
            update fields allowed: triggerid( required), status (0 default enabled/1), priority, expression
        :return:
        '''
        if type(triggerids) is not list:
            triggerids = [triggerids,]
        try:
            result = self.client.call('trigger.delete', triggerids)
            LOG.info("Delete trigger: %s" % json.dumps(result, indent=1))
        except ZabbixClientError as e:
            LOG.error("Delete trigger failed. Caused by %s" % e.message)
            raise Exception("Delete trigger failed. Caused by %s" % e.message)
        return result

    @pre_call
    def get_email_list(self, filters = None):
        if self.mailtypeid == None:
            self.config_notification_actions()
        params = {
            'output' : ["mediaid ","sendto", "severity", "active", "mediatypeid", "period"],
            'userids': "1",
            'mediatypeids': self.mailtypeid
        }
        if filters:
            params.update({'filter': filters})
        result = self.client.call('usermedia.get', params)
        LOG.debug("Get email notification list: %s" % json.dumps(result, indent=1))
        return result

    @pre_call
    def create_email(self, sendto, active, severity):
        '''
        :param sendto:  email address string
        :param active:  0: active, 1: disabled
        :param severity:  severity mask
        :return:
        '''
        if self.mailtypeid == None:
            self.config_notification_actions()
        params = {
            "users": {"userid": "1"},
            "medias": {
                "mediatypeid": self.mailtypeid,
                "sendto": sendto,
            "active": active,
            "severity": severity,
            "period": "1-7,00:00-24:00"
            }
        }
        try:
            result = self.client.call('user.addmedia', params)
            LOG.info("Created email: %s" % json.dumps(result, indent=1))
        except ZabbixClientError as e:
            LOG.error("Create email failed. Caused by %s" % e.message)
            raise Exception("Create email failed. Caused by %s" % e.message)
        return result

    @pre_call
    def update_email(self, mediaid, sendto, active, severity):
        # LOG.info("Calling to update email: %s %s %s %s" % (mediaid, sendto, active, severity))
        current = self.get_email_list()
        for i in current:
            if str(i["mediaid"]) == str(mediaid):
                if sendto is not None: i["sendto"] = sendto
                if active is not None: i["active"] = active
                if severity is not None: i["severity"] = severity
        params = {
            "users": {"userid": "1"},
            "medias": current
        }
        try:
            result = self.client.call('user.updatemedia', params)
            LOG.info("Update email: %s" % json.dumps(result, indent=1))
        except ZabbixClientError as e:
            LOG.error("Update email failed. Caused by %s" % e.message)
            raise Exception("Update email failed. Caused by %s" % e.message)
        return result

    @pre_call
    def delete_email(self, mediaids):
        todelete = []
        current = self.get_email_list()
        currentlists = [str(i["mediaid"]) for i in current]
        if type(mediaids) is not list:
            mediaids = [mediaids,]
        for id in mediaids:
            if str(id) in currentlists:
                todelete.append(id)
        if todelete:
            try:
                result = self.client.call('user.deletemedia', todelete)
                LOG.info("Delete email: %s" % json.dumps(result, indent=1))
            except ZabbixClientError as e:
                LOG.error("Delete email failed. Caused by %s" % e.message)
                raise Exception("Delete email failed. Caused by %s" % e.message)
            return result
        else:
            raise Exception("No email to delete for id: %s" % mediaids)

    @pre_call
    def get_triggerprototypes_by_filter(self, filters=None):
        '''
        only get triggers from "SDS templates"
        :param filters:
        :return:
        '''
        self.has_templates()
        params = {
            'output': 'extend',#['triggerid','priority','description','expression','status'],
            # 'selectHosts': ['hostid', 'name'],
            # 'selectFunctions': 'extend',
            'templateids': [ i['templateid'] for i in self.template_ids ],
            'expandExpression': 1
        }
        if filters:
            params.update({'filter': filters})
        result = self.client.call('triggerprototype.get', params)
        LOG.debug("Retrieved %d triggerprototype by filter%s: %s" % (len(result), str(filters), json.dumps(result, indent=1)))
        return result

    @pre_call
    def update_triggerprototype(self, params):
        '''
        :param params:
            update fields allowed: triggerid( required), status (0 default enabled/1), priority, expression
        :return:
        '''
        try:
            result = self.client.call('triggerprototype.update', params)
            LOG.info("Update triggerprototype: %s" % json.dumps(result, indent=1))
        except ZabbixClientError as e:
            LOG.error("Update triggerprototype failed. Caused by %s" % e.message)
            raise Exception("Update triggerprototype failed. Caused by %s" % e.message)
        return result

    def create_mailtype(self):
        params = {
            'type': 1,
            'description': 'emailalert',
            'exec_path': 'mail.sh',
            'exec_params': "{ALERT.SENDTO}\r\n{ALERT.SUBJECT}\r\n{ALERT.MESSAGE}\r\n"
        }
        return self.client.mediatype.create(params)

    def create_traptype(self):
        params = {
            'type': 1,
            'description': 'trap',
            'exec_path': 'trap.sh',
            'exec_params': "{ALERT.SUBJECT}\r\n"
        }
        return self.client.mediatype.create(params)

    def create_mailaction(self, mediatypeid):
        filter = dict(name='emailaction')
        actions = self.client.action.get(output='extend', filter=filter)
        if len(actions) >0:
            try:
                self.enable_emailalerts(1)
            except Exception as e:
                pass
        return
        # if len(actions) == 0:
        #     # LOG.info("Create new action for email script.")
        #     params = {
        #         "name": "emailaction",
        #         "eventsource": 0,
        #         "status": 0,  # enabled by default, alertscript will check global settings before sending mail
        #         "esc_period": 120,
        #         "def_shortdata": "{TRIGGER.NAME}: {TRIGGER.STATUS}",
        #         "def_longdata": "Alert {TRIGGER.ID}:{TRIGGER.NAME}: {TRIGGER.STATUS}\r\n\r\n" \
        #                         + "Alert severity: {TRIGGER.SEVERITY} \r\n\r\n" \
        #                         + "Last value: \r\n {HOST.NAME1}:{ITEM.NAME1}:{ITEM.LASTVALUE}",
        #         "r_shortdata": "{TRIGGER.NAME} Recovered: {TRIGGER.STATUS}",
        #         "r_longdata": "Alert {TRIGGER.ID} Recovered:{TRIGGER.NAME}: {TRIGGER.STATUS}\r\n\r\n" \
        #                       + "Alert severity: {TRIGGER.SEVERITY} \r\n\r\n" \
        #                       + "Last value: \r\n {HOST.NAME1}:{ITEM.NAME1}:{ITEM.LASTVALUE}",
        #         'recovery_msg': 1,  # enabled
        #         "filter": {
        #             "evaltype": 3,
        #             "formula": "A and B",
        #             "conditions": [
        #                 {
        #                     "conditiontype": 16,
        #                     "operator": 7,
        #                     "value": "",
        #                     "formulaid": "A"
        #                 },
        #                 {
        #                     "conditiontype": 5,
        #                     "operator": 0,
        #                     "value": "1",
        #                     "formulaid": "B"
        #                 }
        #             ]
        #         },
        #         "operations": [
        #             {
        #                 "operationtype": 0,
        #                 "esc_period": 0,
        #                 "esc_step_from": 1,
        #                 "esc_step_to": 1,
        #                 "evaltype": 0,
        #                 "opmessage_usr": [
        #                     {
        #                         "userid": "1"
        #                     }
        #                 ],
        #                 "opmessage": {
        #                     "default_msg": 1,
        #                     "mediatypeid": mediatypeid
        #                 }
        #             }
        #         ]
        #     }
        #
        #     result = self.client.action.create(params)
        #     LOG.info("Create action: %s" % json.dumps(result, indent=1))
        # else:
        #     LOG.info("Action already exists: %s" % json.dumps(actions, indent=1))

    def create_trapaction(self, mediatypeid):
        filter = dict(name='trapaction')
        actions = self.client.action.get(output='extend', filter=filter)
        if len(actions) == 0:
            params = {
                "name": "trapaction",
                "eventsource": 0,
                "status": 0,  # enabled by default, alertscript will check global settings before sending mail
                "esc_period": 120,
                "def_shortdata": "{TRIGGER.ID}",
                "r_shortdata": "{TRIGGER.ID}",
                'recovery_msg': 1,  # enabled
                "filter": {
                    "evaltype": 3,
                    "formula": "A and B",
                    "conditions": [
                        {
                            "conditiontype": 16,
                            "operator": 7,
                            "value": "",
                            "formulaid": "A"
                        },
                        {
                            "conditiontype": 5,
                            "operator": 0,
                            "value": "1",
                            "formulaid": "B"
                        }
                    ]
                },
                "operations": [
                    {
                        "operationtype": 0,
                        "esc_period": 0,
                        "esc_step_from": 1,
                        "esc_step_to": 1,
                        "evaltype": 0,
                        "opmessage_usr": [
                            {
                                "userid": "1"
                            }
                        ],
                        "opmessage": {
                            "default_msg": 1,
                            "mediatypeid": mediatypeid
                        }
                    }
                ]
            }
            result = self.client.action.create(params)
            LOG.info("Create action: %s" % json.dumps(result, indent=1))
        else:
            LOG.info("Trap Action already exists: %s" % json.dumps(actions, indent=1))

    def create_trap_media(self, mediatypeid):
        params = {
            'output' : ["mediaid "],
            'userids': "1",
            'mediatypeids': mediatypeid
        }
        result = self.client.call('usermedia.get', params)
        if len(result) >0:
            LOG.info("Trap media already exists.")
            return result
        params = {
            "users": {"userid": "1"},
            "medias": {
                "mediatypeid": mediatypeid,
                "sendto": "ANY",
            "active": 0,
            "severity": 63,
            "period": "1-7,00:00-24:00"
            }
        }
        try:
            result = self.client.call('user.addmedia', params)
            LOG.info("Created media trap: %s" % json.dumps(result, indent=1))
        except ZabbixClientError as e:
            LOG.error("Create trap media failed. Caused by %s" % e.message)
            raise Exception("Create trap media failed. Caused by %s" % e.message)
        return result

    @pre_call
    def config_notification_actions(self):
        try:
            create_trap = True
            create_mail = False
            traptypeid = None
            filter = dict(type=1)
            mediatypes = self.client.mediatype.get(output='extend', filter=filter)
            for mtype in mediatypes:
                if mtype['description'] == 'emailalert':
                    self.mailtypeid = mtype["mediatypeid"]
                    LOG.info("Mediatype id %s for email script already exists. Need disable action" % self.mailtypeid)

                    create_mail = False
                if mtype['description'] == 'trap':
                    traptypeid = mtype["mediatypeid"]
                    create_trap = False

            if create_mail:
                LOG.info("Create new mediatype id %s for email script." % self.mailtypeid)
                ret = self.create_mailtype()
                self.mailtypeid = ret["mediatypeids"][0]
            if create_trap:
                LOG.info("Create new mediatype id %s for trap script." % self.mailtypeid)
                ret = self.create_traptype()
                traptypeid = ret["mediatypeids"][0]

            self.create_mailaction(self.mailtypeid) # disable now
            self.create_trapaction(traptypeid)
            self.create_trap_media(traptypeid)
            return True
        except ZabbixClientError as e:
            LOG.error("Configure email actions failed. Caused by %s" % e.message)
            raise Exception("Configure email actions failed. Caused by %s" % e.message)

    @pre_call
    def get_emailalertflag(self):
        '''
        :return:  0: enabled, 1: disabled
        '''
        if self.mailtypeid == None:
            self.config_notification_actions()
        filter = dict(name='emailaction')
        try:
            actions = self.client.action.get(output=['status'], filter=filter)
            LOG.info("Email action enablement flag: %s" % str(actions[0]['status']))
            return actions[0]['status']
        except Exception as e:
            LOG.error("Failed to get email alert setting. Caused by %s" % e.message)
            raise Exception("Failed to get email alert setting. Caused by %s" % e.message)

    @pre_call
    def enable_emailalerts(self, flag):
        '''
        :param flag:  0: enabled. 1: disabled
        :return:
        '''
        if self.mailtypeid == None:
            self.config_notification_actions()
        filter = dict(name='emailaction')
        try:
            actions = self.client.action.get(output='extend', filter=filter)
            id = actions[0]['actionid']
            params = {
                "actionid": id,
                "status": flag
            }
            self.client.action.update(params)
            LOG.info("Enable/disable email actions: %s" % str(flag))
            return True
        except Exception as e:
            raise Exception("Failed to update email action caused by %s" % e.message)

    @pre_call
    def get_latest_zabbix_events(self, old_event_id, objectids):
        """
        :param old_event_id: the old max event id
        :param objectids: the list of the trigger id-s
        :return: a event list
        """
        try:
            params = {
                'source': 0,
                'objectids': objectids,
                'eventid_from': str(old_event_id + 1)
            }
            return self.client.call('event.get', params)
        except Exception as ex:
            LOG.error("Failed to get latest zabbix events: %s" % ex)
            raise

    @pre_call
    def get_datavalue_by_triggerid_and_timestamp(self, trigger_id, timestamp):
        """
        :param trigger_id: the triggerid in zabbix DB's trigger table
        :param timestamp: the timestamp when the event occurred
        :return: the value of the item_id in zabbix DB's history table
        """
        try:
            trigger_get_params = {
                'triggerids': trigger_id,
                'selectFunctions': 'extend',
            }

            r1 = self.client.call('trigger.get', trigger_get_params)
            item_id = r1[0]['functions'][0]['itemid']

            history_get_params = {
                'history': 0,  # numeric float
                'itemids': item_id,
                'time_from': timestamp,
                'time_till': timestamp
            }
            r2 = self.client.call('history.get', history_get_params)
            if r2:
                datavalue = float(r2[0]['value'])
            else:
                datavalue = -1
            return datavalue

        except Exception as ex:
            LOG.error("Failed to get history value by trigger id and timestamp: %s" % ex)
            raise
