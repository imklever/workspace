# -*- coding: utf-8 -*-

from storagemgmt.openstack.common import log
from storagemgmt.common.kpifactory.cpu import CPU
from storagemgmt.common.kpifactory.memory import Memory
from storagemgmt.common.kpifactory.disk import Disk
from storagemgmt.common.kpifactory.physical_disk import PhyDisk
from storagemgmt.common.kpifactory.network import Network
from storagemgmt.common.kpifactory.ceph_cluster import CephCluster
from storagemgmt.common.kpifactory.pool import Pool
from storagemgmt.common.kpifactory.rbd import RBD
from storagemgmt.common.kpifactory.monitor import Monitor
from storagemgmt.common.kpifactory.osd import OSD

LOG = log.getLogger(__name__)

class KPIFactory(object):
    def create_kpi(self, **kwargs):
        if kwargs['target'] == 'cpu':
            return CPU(**kwargs)
        if kwargs['target'] == 'mem':
            return Memory(**kwargs)
        if kwargs['target'] == 'disk':
            return Disk(**kwargs)
        if kwargs['target'] == 'phydisk':
            return PhyDisk(**kwargs)
        if kwargs['target'] == 'net':
            return Network(**kwargs)
        if kwargs['target'] == 'cluster':
            return CephCluster(**kwargs)
        if kwargs['target'] == 'pool':
            return Pool(**kwargs)
        if kwargs['target'] == 'rbd':
            return RBD(**kwargs)
        if kwargs['target'] == 'mon':
            return Monitor(**kwargs)
        if kwargs['target'] == 'osd':
            return OSD(**kwargs)
