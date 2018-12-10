# -*- coding: utf-8 -*-

import json
from storagemgmt.api.hooks import DBHook
from storagemgmt.openstack.common import log
from storagemgmt.storage.sqlalchemy.models import Host
from storagemgmt.common.zab_client import ZabbixClient
from storagemgmt.common.rpc_client import RpcClient

LOG = log.getLogger(__name__)

class ZabbixUtil(object):
    """
    Utility to handle zabbix 
    """
    def get_zabbix_client(self, dbconn, clusterId):
        serverIp, user, password = dbconn.tbClusterConf.get_zabbix_config(clusterId)
        if serverIp:
            client = ZabbixClient(serverIp, user, password)
            if not client:
                LOG.warn('Failed to connect to zabbix server: %s' % serverIp)
            interval = self.__get_zabbix_kpi_interval(dbconn, clusterId)
            client.set_interval(interval)
            return client
        else :
            LOG.warn('Zabbix server ip is not configured or can not get server!')
        return None
        
    def check_zabbix_reachable(self, serverIp, user, password):
        if serverIp:
            try:
                client = ZabbixClient(serverIp, user, password)
                if client:
                    return True
                else:
                    return False
            except Exception as e:
                return False
        return False

    def get_zabbix_hostid(self, dbconn, zabbixClient, server):
        if server.zabbixhostid:
            return server.zabbixhostid
        #status = self.__get_zabbix_kpi_status(dbconn, server.clusterid)
        #if zabbixClient and zabbixClient.has_configured():
        #    return self.__add_host_to_zabbix2(dbconn, zabbixClient, server, status)
        return None

    def get_zabbix_cluster_hostid(self, cluster, targetInfo):
        if targetInfo['target'] == 'rbd':
            if cluster.rbd_zabbix_hosts:
                item_name = targetInfo['item_name']
                index = str(abs(hash(item_name)) % 3 + 1)
                rbd_hosts = json.loads(cluster.rbd_zabbix_hosts)
                if rbd_hosts.has_key(index):
                    [host_name, port, host_id] = rbd_hosts[index]
                    return host_id
            return None
        return cluster.zabbix_hostid

    def add_newly_host_to_zabbix(self, dbconn, clusterId, serverId, serverName, serverIp, rpcClient=None):
        zabbixClient = self.get_zabbix_client(dbconn, clusterId)
        status = self.__get_zabbix_kpi_status(dbconn, clusterId)
        if zabbixClient and zabbixClient.has_configured():
            return self.__add_host_to_zabbix1(dbconn, zabbixClient, status,
                                              serverId, serverName, serverIp, rpcClient)
        return None

    def _setup_zab_agent(self, zabbix_server_ip, serverName, serverIP, rpcClient):
        if rpcClient:
            rpcClient.setup_zab_agent(zabbix_server_ip, serverName, serverIP)
        else:
            RpcClient.setup_agent(zabbix_server_ip, serverName, serverIP)

    def _setup_zab_ceph(self, zabbix_server_ip, serverName, ceph_host_name, rpcClient):
        if rpcClient:
            rpcClient.setup_zab_ceph(zabbix_server_ip, serverName, ceph_host_name)
        else:
            RpcClient.setup_ceph_agent(zabbix_server_ip, serverName, ceph_host_name)

    def _stop_zab_ceph(self, zabbix_server_ip, serverName, ceph_host_name, rpcClient):
        if rpcClient:
            rpcClient.stop_zab_ceph(zabbix_server_ip, serverName, ceph_host_name)
        else:
            RpcClient.stop_ceph_agent(zabbix_server_ip, serverName, ceph_host_name)

    def __add_host_to_zabbix1(self, dbconn, zabbixClient, kpiStatus, serverId, serverName, serverIP, rpcClient=None):
        LOG.info('Register server to zabbix...')
        self._setup_zab_agent(zabbixClient.zabbix_server, serverName, serverIP, rpcClient)
        hostId = zabbixClient.add_host(serverId, serverIP, kpiStatus)
        if hostId:
            dbconn.tbHost.update_host_zabbix_id(serverId, hostId)
            return hostId
        else:
            LOG.warn('Failed to add host to zabbix for server %s' % serverName)
            return None

    def __add_host_to_zabbix2(self, dbconn, zabbixClient, server, kpiStatus, rpcClient=None):
        LOG.info('Register server to zabbix...')
        self._setup_zab_agent(zabbixClient.zabbix_server, server.servername, server.publicip, rpcClient)
        hostId = zabbixClient.add_host(server.id, server.publicip, kpiStatus)
        if hostId:
            dbconn.tbHost.update_host_zabbix_id(server.id, hostId)
            return hostId
        else:
            LOG.warn('Failed to add host to zabbix for server %s' % server)

    def add_ceph_cluster_host(self, dbconn, zabbixClient, clusterId, rpcClient):
        master = dbconn.tbHost.get_master_mon_host(clusterId)
        if not master:
            LOG.warn('No master monitor when add ceph zabbix host {}'.format(clusterId))
            return None

        zabbix_ip = zabbixClient.zabbix_server
        ceph_host_name = 'cephcluster{}'.format(clusterId)
        self._setup_zab_ceph(zabbix_ip, master.servername, ceph_host_name, rpcClient)
        kpiStatus = self.__get_zabbix_kpi_status(dbconn, clusterId)
        host_id = zabbixClient.add_ceph_host(ceph_host_name, master.publicip, kpiStatus)
        rbd_hosts = zabbixClient.add_rbd_hosts(ceph_host_name, master.publicip, kpiStatus)
        data = dict()
        if host_id and rbd_hosts:
            data['zabbix_hostname'] = ceph_host_name
            data['zabbix_hostid'] = host_id
            data['zabbix_agent_ip'] = master.publicip
            data['rbd_zabbix_hosts'] = json.dumps(rbd_hosts)
            dbconn.tbCluster.update_by_id(clusterId, data)
            return data
        else:
            LOG.error('Failed to add Ceph cluster host to zabbix for cluster %s' % clusterId)
            return None
    
    def update_ceph_cluster_host(self, dbconn, zabbixClient, clusterId, rpcClient, new_host):
        cluster = dbconn.tbCluster.get_by_id(clusterId)
        old_host = dbconn.tbHost.get_host_by_publicip(clusterId, cluster.zabbix_agent_ip)
        zabbix_ip = zabbixClient.zabbix_server
        ceph_host_name = cluster.zabbix_hostname
        self._setup_zab_ceph(zabbix_ip, new_host.servername, ceph_host_name, rpcClient)
        rbd_zabbix_hosts = json.loads(cluster.rbd_zabbix_hosts)
        result1 = zabbixClient.update_ceph_host(cluster.zabbix_hostid, new_host.publicip)
        result2 = zabbixClient.update_rbd_hosts(rbd_zabbix_hosts, new_host.publicip)
        if result1 and result2:
            data = dict()
            data['zabbix_agent_ip'] = new_host.publicip
            dbconn.tbCluster.update_by_id(clusterId, data)
            self._stop_zab_ceph(zabbix_ip, old_host.servername, ceph_host_name, rpcClient)
        else:
            LOG.error('Failed to update Ceph cluster host to zabbix for cluster %s' % clusterId)
            return None

    def add_cluster_to_zabbix(self, dbconn, clusterId, rpcClient=None):
        zabbixClient = self.get_zabbix_client(dbconn, clusterId)
        status = self.__get_zabbix_kpi_status(dbconn, clusterId)
        if zabbixClient and zabbixClient.has_configured():
            self.add_ceph_cluster_host(dbconn, zabbixClient, clusterId, rpcClient)
            hostList = dbconn.tbHost.get_deployed(clusterId)
            for server in hostList:
                self.__add_host_to_zabbix2(dbconn, zabbixClient, server, status, rpcClient)

    def renew_cluster_to_zabbix(self, dbconn, clusterId, rpcClient=None):
        zabbixClient = self.get_zabbix_client(dbconn, clusterId)
        if not zabbixClient:
            return
        status = self.__get_zabbix_kpi_status(dbconn, clusterId)
        cluster = dbconn.tbCluster.get_by_id(clusterId)
        zabbixClient.import_templates() # always do import first
        if zabbixClient.has_configured():
            if not cluster.zabbix_hostid:
                self.add_ceph_cluster_host(dbconn, zabbixClient, clusterId, rpcClient)
            hostList = dbconn.tbHost.get_deployed(clusterId)
            for server in hostList:
                if not server.zabbixhostid:
                    self.__add_host_to_zabbix2(dbconn, zabbixClient, server, status, rpcClient)
                else:
                    self.__update_host_kpi_status(zabbixClient, server.zabbixhostid, status)

    def __update_host_kpi_status(self, zabbixClient, zabbixhostid, status):
        if status == "disable":
            zabbixClient.unlink_host_template(zabbixhostid)
        else:
            zabbixClient.link_host_template(zabbixhostid)

    def change_zabbix_server(self, dbconn, clusterId, rpcClient=None):
        self.reset_cluster_zabbix_host_id(dbconn, clusterId)
        self.add_cluster_to_zabbix(dbconn, clusterId, rpcClient)
        
    def reset_cluster_zabbix_host_id(self, dbconn, clusterId):
        hostList = dbconn.tbHost.get_hosts_by_clusterid(clusterId)
        for server in hostList:
            dbconn.tbHost.update_host_zabbix_id(server.id, 0)

    def __get_zabbix_kpi_status(self, dbconn, clusterId):
        status = dbconn.tbClusterConf.get_special_conf_by_cluster_id(clusterId, 'zabbix_kpi_status')
        if status:
            return status
        return 'enable' # default

    def __get_zabbix_kpi_interval(self, dbconn, clusterId):
        value = dbconn.tbClusterConf.get_special_conf_by_cluster_id(clusterId, 'zabbix_kpi_interval')
        if value:
            return value
        return 30 # default

    #def get_target_kpi_history(self, dbconn, targetInfo, server, clusterId):
    #    zabbixClient = self.get_zabbix_client(dbconn, clusterId)
    #    if zabbixClient:
    #        if targetInfo['kpi_type'] == 'host':
    #            hostid = self.get_zabbix_hostid(dbconn, zabbixClient, server)
    #        else:
    #            hostid = self.get_zabbix_cluster_hostid(server, targetInfo)
    #        if hostid:
    #            targetInfo['hostid'] = hostid
    #            #LOG.info('leo_result3: %s' % zabbixClient.get_kpi_history(targetInfo))
    #            return zabbixClient.get_kpi_history(targetInfo)
    #    return None

    def get_target_kpi_history(self, dbconn, targetInfo, server, clusterId, time_zone_offset):
        zabbixClient = self.get_zabbix_client(dbconn, clusterId)
        if zabbixClient:
            if targetInfo['kpi_type'] == 'host':
                hostid = self.get_zabbix_hostid(dbconn, zabbixClient, server)
            else:
                hostid = self.get_zabbix_cluster_hostid(server, targetInfo)
            if hostid:
                targetInfo['hostid'] = hostid
                #LOG.info('leo_result3: %s' % zabbixClient.get_kpi_history(targetInfo))
                return zabbixClient.get_kpi_history(targetInfo, time_zone_offset)
        return None

    def get_target_latest_kpi(self, dbconn, targetInfo, server, clusterId):
        zabbixClient = self.get_zabbix_client(dbconn, clusterId)
        if zabbixClient:
            if targetInfo['kpi_type'] == 'host':
                hostid = self.get_zabbix_hostid(dbconn, zabbixClient, server)
            else:
                hostid = self.get_zabbix_cluster_hostid(server, targetInfo)
            if hostid:
                targetInfo['hostid'] = hostid
                return zabbixClient.get_target_latest_kpi(targetInfo)
        return None
