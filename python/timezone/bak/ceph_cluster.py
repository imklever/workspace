# -*- coding: utf-8 -*-

from storagemgmt.common.kpifactory.kpi import KPI

class CephCluster(KPI):
    def __init__(self, **kwargs):
        # kpiMap is for kpi, allMap includes kpi and alert and others
        kpiMap = {'total_capacity' : 'ceph.cluster.total_capacity',
                  'used_capacity'  : 'ceph.cluster.used_capacity',
                  'avail_capacity' : 'ceph.cluster.avail_capacity',
                 }
                 
        otherMap = {'usage_percent'  : 'ceph.cluster.usage_percent',
                          
                    'health'         : 'ceph.cluster.health',

                    #'active_mon_number' : 'ceph.cluster.active_mon_number',
                    #'osd_down_number'   : 'ceph.cluster.osd_down_number',

                    'read_bw'   : 'ceph.cluster.read_bw',
                    'write_bw'  : 'ceph.cluster.write_bw',
                    'read_op'   : 'ceph.cluster.read_op',
                    'write_op'  : 'ceph.cluster.write_op',
                    'recovering_bytes' :'ceph.cluster.recovering_bytes',
                    'recovering_objects' :'ceph.cluster.recovering_objects',
                    }
        allMap = otherMap
        allMap.update(kpiMap)
        super(CephCluster, self).__init__(allMap, kpiMap, None, **kwargs)
