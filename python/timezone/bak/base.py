# -*- coding: utf-8 -*-
__author__ = 'lyj'

from pecan import rest
from storagemgmt.api.hooks import DBHook
from storagemgmt.openstack.common import log
from storagemgmt.storage.sqlalchemy.models import Host
from storagemgmt.common.zab_client import ZabbixClient
from storagemgmt.common.zabbix_util import ZabbixUtil
from storagemgmt.common.rpc_client import RpcClient
from storagemgmt.i18n import _

LOG = log.getLogger(__name__)


class BaseController(rest.RestController):
    """
    Base controller common validation
    """
    def zabbix_get(self, cluster_id, server, method, *args, **kwargs):
        LOG.info("Calling zabbix_get..., clusterid: %s, server: %s, method: %s, args: %s %s" % (cluster_id, server, method, args, kwargs))
        if isinstance(server, Host):
            server_id = server.id
        else:
            server_id = server
        dbconn = DBHook.get_connection()
        server = dbconn.tbHost.get_by_id(server_id)
        zabbix_server_ip = dbconn.tbClusterConf.get_special_conf_by_cluster_id(cluster_id, 'zabbix_server_ip')
        zabbix_user = dbconn.tbClusterConf.get_special_conf_by_cluster_id(cluster_id, 'zabbix_user')
        zabbix_password = dbconn.tbClusterConf.get_special_conf_by_cluster_id(cluster_id, 'zabbix_password')
        if zabbix_server_ip:
            zabbix_client = ZabbixClient(zabbix_server_ip, zabbix_user, zabbix_password)
            if server and server.zabbixhostid:
                if zabbix_client:
                    _method = getattr(zabbix_client, method)
                    _args = list(args)
                    _args.insert(0, server.zabbixhostid)
                    LOG.debug('Args: %s' % _args)
                    return _method(*_args, **kwargs)
                else:
                    LOG.error('Cannot initializing zabbix client with server_url: %s' % zabbix_server_ip)
            elif not server.zabbixhostid:
                LOG.info("Register server to zabbix...")
                if zabbix_client and zabbix_client.has_configured():
                    RpcClient.setup_agent(zabbix_server_ip, server.servername, server.publicip)
                    host_id = zabbix_client.add_host(server.id, server.publicip)
                    if host_id:
                        server = dbconn.tbHost.update_host_zabbix_id(server.id, host_id)
                        if server:
                            _method = getattr(zabbix_client, method)
                            _args = list(args)
                            _args.insert(0, server.zabbixhostid)
                            LOG.info('Args: %s' % _args)
                            return _method(*_args, **kwargs)
            else:
                LOG.error('Server not found. Server id: %s' % server_id)
        else:
            LOG.warn('Zabbix server ip is not configured!')
        return None, None

    def zabbix_call(self, method, *args, **kwargs):
        LOG.info("Calling zabbix_call...method: %s, args: %s %s" % (
        method, args, kwargs))
        dbconn = DBHook.get_connection()
        clusters = dbconn.tbCluster.get_all_without_deleted()
        #now we assume all clusters share the same zabbix server!
        #to optimize
        zabbix_server_ip = None
        for cluster in clusters:
            if not cluster.deleted:
                LOG.debug('zabbix_call cluster id: %d' % cluster.id)
                zabbix_server_ip = dbconn.tbClusterConf.get_special_conf_by_cluster_id(cluster.id, 'zabbix_server_ip')
                zabbix_user = dbconn.tbClusterConf.get_special_conf_by_cluster_id(cluster.id, 'zabbix_user')
                zabbix_password = dbconn.tbClusterConf.get_special_conf_by_cluster_id(cluster.id, 'zabbix_password')
                break
        if zabbix_server_ip:
            zabbix_client = ZabbixClient(zabbix_server_ip, zabbix_user, zabbix_password)
            if zabbix_client:
                _method = getattr(zabbix_client, method)
                _args = list(args)
                LOG.debug('Args: %s' % _args)
                return _method(*_args, **kwargs)
            else:
                LOG.error('Cannot initializing zabbix client with server_url: %s' % zabbix_server_ip)
        else:
            LOG.warn('Zabbix server ip is not configured!')
        return None, None

    def get_target_latest_kpi(self, **kwargs):
        # for cli use
        dbconn = DBHook.get_connection()
        clusterId = kwargs['clusterid']
        if kwargs.has_key('serverid'):
            kpi_type = 'host'
            server = dbconn.tbHost.get_by_id(kwargs['serverid'])
        else:
            kpi_type = 'ceph'
            server = dbconn.tbCluster.get_by_id(clusterId)
        if not server:
            return []
        targetInfo = self.__build_target_info(dbconn, kwargs)
        targetInfo['kpi_type'] = kpi_type
        result = ZabbixUtil().get_target_latest_kpi(dbconn, targetInfo, server, clusterId)
        return result

    def get_kpi_history(self, **kwargs):
        dbconn = DBHook.get_connection()
        clusterId = kwargs['clusterid']
        if kwargs.has_key('serverid'):
            kpi_type = 'host'
            server = dbconn.tbHost.get_by_id(kwargs['serverid'])
        else:
            kpi_type = 'ceph'
            server = dbconn.tbCluster.get_by_id(clusterId)
        if not server:
            raise Exception(_("Failed to get target item"))
        targetInfo = self.__build_target_history_info(dbconn, kwargs)
        targetInfo['kpi_type'] = kpi_type
        #result = ZabbixUtil().get_target_kpi_history(dbconn, targetInfo, server, clusterId)
        result = ZabbixUtil().get_target_kpi_history(dbconn, targetInfo, server, clusterId, kwargs['time_zone_offset'])
        #LOG.info("leo_result2: %s " % result)
        return result

    def __build_target_history_info(self, dbconn, kwargs):
        """
        construct [hostid, target, kpi, item_name] for zabbix item
        eg: hostid: 10045; target: disk; kpi: total_capacity; item_name: /Ceph/Data/Osd/osd-scsi-*
        """
        targetInfo = dict()
        targetInfo['target'] = kwargs['target']
        targetInfo['kpi'] = kwargs['kpi']
        targetInfo['time_from'] = kwargs['time_from']
        targetInfo['time_till'] = kwargs['time_till']
        targetInfo['granularity'] = kwargs['granularity']
        itemName = self.__get_kpi_target_name(dbconn, kwargs)
        if itemName:
            targetInfo['item_name'] = itemName
        return targetInfo
        
    def __build_target_info(self, dbconn, kwargs):
        targetInfo = dict()
        targetInfo['target'] = kwargs['target']
        targetInfo['kpi'] = 'all'
        itemName = self.__get_kpi_target_name(dbconn, kwargs)
        if itemName:
            targetInfo['item_name'] = itemName
        return targetInfo
        
    def __get_kpi_target_name(self, dbconn, kwargs):
        Target = kwargs['target']
        if Target == "disk":
            disk = dbconn.tbDisk.get_by_id(kwargs['diskid'])
            return disk.mounton
        elif Target == 'phydisk':
            phyDisk = dbconn.get_phy_disk_by_id(kwargs['phydiskid'])
            return phyDisk.path
        elif Target == 'net':
            network = dbconn.tbNetwork.get_by_id(kwargs['networkid'])
            return network.name
        elif Target == "pool":
            pool = dbconn.tbPool.get_pool_by_id(kwargs['poolid'])
            return pool.name
        elif Target == "rbd":
            rbd = dbconn.tbRbd.get_by_id(kwargs['rbdid'])
            return "{0},{1}".format(rbd.pool, rbd.image)
        elif Target == 'mon':
            mon = dbconn.get_mon(kwargs['monid'])
            return mon.name
        elif Target == 'osd':
            osd = dbconn.tbOsd.get_by_id(kwargs['osdid'])
            return osd.name
        return None
