#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

import six
import time
import datetime
import logging
LOG = logging.getLogger(__name__)

from cephmgmtclient.common import base
from cephmgmtclient import exc
from cephmgmtclient.v1 import options

CLUSTER_CREATION_ATTRS = ('name',
                          'addr')

SERVER_CREATION_ATTRS = ('servername',
                         'publicip',
                         'clusterip',
                         'username',
                         'passwd',
                         'parent_bucket',
                         'backup_node')

CLUSTER_OPERATTION = ('deploy',
                      'expand',
                      'start',
                      'restart',
                      'shutdown')

COMMON_OPERATTION = ('start',
                     'shutdown',
                     'restart',
                     'start_maintenance',
                     'stop_maintenance')

CAP_OPERATTION = ('start', 'stop')


class CephStorage(base.Resource):
    def __repr__(self):
        return "<CephStorage %s>" % self._info


class UrlChain:
    def __init__(self, path=''):
        self._path = path

    def __getattr__(self, item):
        return UrlChain('%s/%s' % (self._path, item))

    def __str__(self):
        return self._path

    def __call__(self, index):
        return UrlChain('%s/%s' % (self._path, index))


class CephManager(base.Manager):
    resource_class = CephStorage
    base_url = UrlChain('v1')

    def sys_systime(self):
        return self._get(self.base_url.sys.systime)

    def get_clusters(self):
        return self._list(self.base_url.clusters)

    def get_clusterinfo(self, cluster_id):
        return self._get(self.base_url.clusters(cluster_id).summary, None, None)

    def get_cluster_topology(self, cluster_id):
        return self._get(self.base_url.clusters(cluster_id).topology)

    def add_cluster(self, name, addr, cluster_type, **kwargs):
        entity = dict(name=name, addr=addr, cluster_type=cluster_type)
        if not entity:
            raise exc.CommandError('No valid ceph cluster information is provided to '
                                   'create: %s!' % kwargs)
        return self._create(self.base_url.clusters, entity)

    def import_cluster(self, cluster_id, **kwargs):
        return self._update(self.base_url.clusters(cluster_id).servers, kwargs)

    def modify_cluster(self, cluster_id, name, addr, **kwargs):
        if cluster_id is None:
            raise exc.CommandError('must specify ceph cluster id to update!')

        _body = dict(name=name, addr=addr, operation='modify')
        entity = {'entity': _body}
        if not entity:
            raise exc.CommandError('no valid information is provided to '
                                   'update ceph cluster %s: %s!' % (cluster_id, kwargs))
        return self._update(self.base_url.clusters(cluster_id), entity)

    def delete_cluster(self, cluster_id):
        if cluster_id is None:
            raise exc.CommandError('must specify cluster id to delete!')
        self._delete(self.base_url.clusters(cluster_id))

    def cluster_get_phy_disks_health(self, cluster_id):
        return self._get(self.base_url.clusters(cluster_id).phy_disks_health)

    def add_server(self, cluster_id, **kwargs):
        entity = dict((key, value) for (key, value) in kwargs.items()
                      if key in SERVER_CREATION_ATTRS)
        if not entity:
            raise exc.CommandError('no valid information is provided to '
                                   'add host to cluster %s: %s!' % (kwargs, cluster_id))
        return self._create(self.base_url.clusters(cluster_id).servers, entity)

    def cephed_server(self, cluster_id, **kwargs):
        entity = dict((key, value) for (key, value) in kwargs.items()
                      if key in SERVER_CREATION_ATTRS)
        if not entity:
            raise exc.CommandError('no valid information is provided to '
                                   'add cephed host to cluster %s: %s!' % (kwargs, cluster_id))
        return self._update(self.base_url.clusters(cluster_id).servers, entity)

    def modify_server(self, cluster_id, server_id, **kwargs):
        if cluster_id is None:
            raise exc.CommandError('must specify ceph cluster id to update!')
        if server_id is None:
            raise exc.CommandError('must specify ceph server id to update!')

        _body = dict(operation='move')
        entity = {'entity': _body}
        return self._update(self.base_url.clusters(cluster_id).servers(server_id), entity)

    def delete_server(self, cluster_id, server_id):
        if cluster_id is None:
            raise exc.CommandError('must specify cluster id to update!')
        if server_id is None:
            raise exc.CommandError('must specify ceph server id to delete!')
        self._delete(self.base_url.clusters(cluster_id).servers(server_id))

    def manipulate_cluster(self, cluster_id, operation):
        if cluster_id is None:
            raise exc.CommandError('must specify cluster id to update!')

        if operation not in CLUSTER_OPERATTION:
            raise exc.CommandError('must specify valid operation to manipulate cluster')

        entity = {'entity': {'operation': operation}}
        return self._update(self.base_url.clusters(cluster_id), entity)

    def manipulate_server(self, cluster_id, server_id, operation):
        if cluster_id is None:
            raise exc.CommandError('must specify cluster id to update!')
        if server_id is None:
            raise exc.CommandError('must specify ceph server id to manipulate!')

        if operation not in COMMON_OPERATTION:
            raise exc.CommandError('must specify valid operation to manipulate server')

        entity = {'entity': {'operation': operation}}
        return self._update(self.base_url.clusters(cluster_id).servers(server_id), entity)

    def create_job(self, **kwargs):
        entity = dict((k, v) for (k, v) in kwargs.items())
        if not entity:
            raise exc.CommandError('no valid information is provided to '
                                   'add create job %s!' % kwargs)
        job = self._create(self.base_url.jobs, entity)
        return job.id

    # def get_job(self, job_id):
    #     if not job_id:
    #         raise exc.CommandError('no valid job id is provided to retrieve job status!')
    #     job_status = self._get(self.base_url.jobs(job_id))
    #     return job_status

    def get_networks(self, cluster_id, server_id, **kwargs):
        if cluster_id is None:
            raise exc.CommandError('must specify cluster id!')
        if server_id is None:
            raise exc.CommandError('must specify ceph server id!')
        networks_path = self.base_url.clusters(cluster_id).servers(server_id).networks
        return self._list(networks_path)

    def get_history(self, entity_id, item_type, item_name=None, **kwargs):
        if item_type is None:
            raise exc.CommandError('must specify item_type!')
        if type is None:
            raise exc.CommandError('must specify query entity type!')

        # we need encode query params here
        entity = {
            'entity_id': entity_id,
            'item_type': item_type
        }
        item_name and entity.update({'item_name': item_name})
        kwargs and entity.update(kwargs)

        return self._get(options.build_url_encoded(str(self.base_url.history), None, entity))

    def get_utcOffset(self):
        timestamp = time.time()
        time_now = datetime.datetime.fromtimestamp(timestamp)
        time_utc = datetime.datetime.utcfromtimestamp(timestamp)
        offset = int((time_now -time_utc).total_seconds() / 3600)
        return offset

    def horizon2local(self,horizon_timezone,horizon_time):

        #get horizon time
        timeStruct = time.strptime(horizon_time, '%Y-%m-%d %H:%M:%S')
        timeStamp=int(time.mktime(timeStruct))

        #horizon time->UTC time
        timeStamp -= 3600*int(horizon_timezone)
        timeStruct = time.localtime(timeStamp)
        strTime = time.strftime("%Y-%m-%d %H:%M:%S", timeStruct)

        #UTC time -> local time
        offset = self.get_utcOffset()
        timeStamp += 3600*offset
        timeStruct = time.localtime(timeStamp)
        strTime = time.strftime("%Y-%m-%d %H:%M:%S", timeStruct)

        return strTime


    def get_kpi_history(self, **kwargs):
        itemList = ('clusterid', 'target', 'kpi',
                    'time_from', 'time_till', 'time_zone_offset', 'granularity')
        for item in itemList:
            if not kwargs.has_key(item):
                raise exc.CommandError('must specify {}!'.format(item))
            if item == 'time_zone_offset':
                time_zone=kwargs[item].strip()
                kwargs['time_from']=self.horizon2local(time_zone, kwargs['time_from'])
                kwargs['time_till']=self.horizon2local(time_zone, kwargs['time_till'])
                
        entity = dict()
        entity.update(kwargs)

        LOG.info('hahahahahaha: %s' % kwargs['time_zone_offset'])

        result = self._get(options.build_url_encoded(str(self.base_url.kpi), None, entity))
        LOG.info("result: %s" % result)
        #return self._get(options.build_url_encoded(str(self.base_url.kpi), None, entity))
        return result

    def kpi_export(self, **kwargs):
        itemList = ('format', 'cluster', 'clusterid', 'time_from', 'time_till', 'granularity')
        for item in itemList:
            if not kwargs.has_key(item):
                raise exc.CommandError('must specify {}!'.format(item))

        entity = dict()
        entity.update(kwargs)

        return self._get(options.build_url_encoded(str(self.base_url.kpi.export), None, entity))

    def get_latest_kpi(self, **kwargs):
        itemList = ('clusterid', 'target')
        for item in itemList:
            if not kwargs.has_key(item):
                raise exc.CommandError('must specify {}!'.format(item))
                
        entity = dict()
        entity.update(kwargs)

        return self._list(options.build_url_encoded(str(self.base_url.kpi.latest), None, entity))

    def get_osds_capacity(self, cluster_id, server_id):

        if not cluster_id:
            raise exc.CommandError('no valid cluster id is provided to retrieve osds!')
        if not server_id:
            raise exc.CommandError('no valid server id is provided to retrieve osds!')
        return self._get(self.base_url.clusters(cluster_id).servers(server_id).osds_capacity, None)

    def get_disk_list(self, cluster_id, server_id, osd_id):
        if not cluster_id:
            raise exc.CommandError('no valid cluster id is provided to retrieve disks!')
        if not server_id:
            raise exc.CommandError('no valid server id is provided to retrieve disks!')
        if not osd_id:
            raise exc.CommandError('no valid osd id is provided to retrieve disks!')
        return self._list(self.base_url.clusters(cluster_id).servers(server_id).osds(osd_id).disks, None, None)

    def manipulate_osd(self, cluster_id, server_id, osd_id, operation):
        if not cluster_id:
            raise exc.CommandError('no valid cluster id is provided to operate osd!')
        if not server_id:
            raise exc.CommandError('no valid server id is provided to operate osd!')
        if not osd_id:
            raise exc.CommandError('no valid osd id is provided to operate osd!')

        entity = {"entity": {"operation": operation}}
        return self._update(self.base_url.clusters(cluster_id).servers(server_id).osds(osd_id), entity)

    def get_cluster_conf(self, cluster_id):
        if not cluster_id:
            raise exc.CommandError('no valid cluster id provided to retrieve cluster config!')

        return self._get(self.base_url.clusters(cluster_id).config)

    def modify_cluster_conf(self, cluster_id, **kwargs):
        if not cluster_id:
            raise exc.CommandError('no valid cluster id provided to modify cluster config!')

        if not kwargs:
            raise exc.CommandError('no valid properties provided to update cluster config!')
        entity = dict()
        entity.update(kwargs)
        return self._update(self.base_url.clusters(cluster_id).config, entity)

    def get_pools(self, cluster_id, **kwargs):
        return self._get(options.build_url_encoded(str(self.base_url.clusters(cluster_id).pools), None, kwargs))

    def add_pool(self, cluster_id, **kwargs):
        if not cluster_id:
            raise exc.CommandError('no valid cluster id provided to add pool!')
        body = dict()
        body.update(kwargs)
        return self._create(self.base_url.clusters(cluster_id).pools, body)

    def modify_pool(self, cluster_id, pool_id, **kwargs):
        if not cluster_id:
            raise exc.CommandError('no valid cluster id is provided to modify pool!')
        if not pool_id:
            raise exc.CommandError('no valid id is provided to modify pool!')
        entity = dict()
        entity.update(kwargs)
        return self._update(self.base_url.clusters(cluster_id).pools(pool_id), entity)

    def del_pool(self, cluster_id, pool_id):
        if not cluster_id:
            raise exc.CommandError('no valid cluster id is provided to delete pool!')
        if not pool_id:
            raise exc.CommandError('no valid id is provided to delete pool!')
        return self._delete(self.base_url.clusters(cluster_id).pools(pool_id))

    def option_pool(self, cluster_id, pool_id, **kwargs):
        if not cluster_id:
            raise exc.CommandError('No valid cluster id is provided to set cache pool!')
        if not pool_id:
            raise exc.CommandError('No valid id is provided to set cache pool!')
        option_data = dict()
        option_data.update(kwargs)
        return self._update(self.base_url.clusters(cluster_id).pools(pool_id).option, option_data)

    def create_rbd(self, cluster_id, pool_id, **kwargs):
        '''
          kwargs need contain:name, capacity, size
        '''
        if not cluster_id:
            raise exc.CommandError('No valid cluster id provided to create rbd!')
        if not pool_id:
            raise exc.CommandError('No valid server id is provided to create rbd!')
        if not kwargs:
            raise exc.CommandError('Not enough params to create rbd')
        if not kwargs.has_key("name") or not kwargs.has_key("capacity") or not kwargs.has_key("object_size"):
            raise exc.CommandError('Not enough params to create rbd')
        entity = {"entity": kwargs}
        return self._create(self.base_url.clusters(cluster_id).pools(pool_id).rbds, entity)

    def delete_rbd(self, cluster_id, pool_id, rbd_id, **kwargs):
        if kwargs:
            return self._delete_with_response(self.base_url.clusters(cluster_id).pools(pool_id).rbds(rbd_id), kwargs)
        else:
            return self._delete_with_pack_response(self.base_url.clusters(cluster_id).pools(pool_id).rbds(rbd_id))

    def add_mon(self, cluster_id, server_id):
        if not cluster_id:
            raise exc.CommandError('no valid cluster id provided to add monitor!')
        if not server_id:
            raise exc.CommandError('no valid server id is provided to add monitor!')
        entity = dict()
        return self._create(self.base_url.clusters(cluster_id).servers(server_id).mons, entity)

    def manipulate_monitor(self, cluster_id, server_id, monitor_id, operation):
        if not cluster_id:
            raise exc.CommandError('no valid cluster id is provided to manipulate monitor!')
        if not server_id:
            raise exc.CommandError('no valid server id is provided to manipulate monitor!')
        if not monitor_id:
            raise exc.CommandError('no valid monitor id is provided to manipulate monitor!')
        entity = {'operation': operation}
        return self._update(self.base_url.clusters(cluster_id).servers(server_id).mons(monitor_id), entity)

    def del_monitor(self, cluster_id, server_id, monitor_id):
        if not cluster_id:
            raise exc.CommandError('no valid cluster id is provided to delete monitor!')
        if not server_id:
            raise exc.CommandError('no valid server id is provided to delete monitor!')
        if not monitor_id:
            raise exc.CommandError('no valid monitor id is provided to delete monitor!')
        return self._delete(self.base_url.clusters(cluster_id).servers(server_id).mons(monitor_id))

    def get_avail_disks(self, cluster_id, server_id):
        if not cluster_id:
            raise exc.CommandError('no valid cluster id is provided to retrieve available disks!')
        if not server_id:
            raise exc.CommandError('no valid server id is provided to retrieve available disks!')
        return self._list(self.base_url.clusters(cluster_id).servers(server_id).availdisks)
        
    def get_ceph_disks(self, cluster_id, server_id):
        if not cluster_id:
            raise exc.CommandError('no valid cluster id is provided to retrieve ceph disks!')
        if not server_id:
            raise exc.CommandError('no valid server id is provided to retrieve ceph disks!')
        return self._list(self.base_url.clusters(cluster_id).servers(server_id).cephdisks)

    def add_osd(self, cluster_id, server_id, disks):
        if not cluster_id:
            raise exc.CommandError('no valid cluster id is provided to add disks!')
        if not server_id:
            raise exc.CommandError('no valid server id is provided to add disks!')
        entity = dict(uuids=disks)
        return self._create(self.base_url.clusters(cluster_id).servers(server_id).osds, entity)

    def delete_osd(self, cluster_id, server_id, osd_id):
        if not cluster_id:
            raise exc.CommandError('no valid cluster id is provided to delete osd!')
        if not server_id:
            raise exc.CommandError('no valid server id is provided to delete osd!')
        if not osd_id:
            raise exc.CommandError('no valid monitor id is provided to delete osd!')
        return self._delete(self.base_url.clusters(cluster_id).servers(server_id).osds(osd_id))

    def modify_rbd(self, cluster_id, pool_id, rbd_id, **kwargs):
        if not (type(cluster_id)==int):
            raise exc.CommandError('No valid cluster id is provided to modify rbd!')
        if not (type(pool_id)==int):
            raise exc.CommandError('No valid pool id is provided to modify rbd!')
        if not (type(rbd_id)==int):
            raise exc.CommandError('No valid rbd id is provided to modify rbd!')
        entity = {"entity":kwargs}
        if "operation" in kwargs and kwargs["operation"] == "move":
            return self._update(self.base_url.clusters(cluster_id).pools(pool_id).rbds(rbd_id).moverbd, entity)
        if "operation" in kwargs and kwargs["operation"] == "copy":
            return self._update(self.base_url.clusters(cluster_id).pools(pool_id).rbds(rbd_id).copyrbd, entity)

        return self._update(self.base_url.clusters(cluster_id).pools(pool_id).rbds(rbd_id), entity)

    def get_snapshots(self,cluster_id, pool_id, rbd_id):
        if not (type(cluster_id)==int):
            raise exc.CommandError('No valid cluster id is provided to get snaps!')
        if not (type(pool_id)==int):
            raise exc.CommandError('No valid pool id is provided to get snaps!')
        if not (type(rbd_id)==int):
            raise exc.CommandError('No valid rbd id is provided to get snaps!')
        return self._list(self.base_url.clusters(cluster_id).pools(pool_id).rbds(rbd_id).snapshots)

    def delete_snapshot(self,cluster_id, pool_id, rbd_id, snapshot_id):
        if not (type(cluster_id)==int):
            raise exc.CommandError('No valid cluster id is provided to delete snap!')
        if not (type(pool_id)==int):
            raise exc.CommandError('No valid pool id is provided to delete snap!')
        if not (type(rbd_id)==int):
            raise exc.CommandError('No valid rbd id is provided to delete snap!')
        if not (type(snapshot_id)==int):
            raise exc.CommandError('No valid snap id provided to delete snap!')
        return self._delete(self.base_url.clusters(cluster_id).pools(pool_id).rbds(rbd_id).snapshots(snapshot_id))

    def get_cluster_monitors(self, cluster_id):
        if not (type(cluster_id)==int):
            raise exc.CommandError('Cluster id should be integer provided to get monitor!')
        return self._list(self.base_url.clusters(cluster_id).mons)

    def get_mdses(self, cluster_id):
        if not cluster_id:
            raise exc.CommandError('no valid cluster id provided to retrieve cluster pools!')

        return self._list(self.base_url.clusters(cluster_id).mdses)

    def add_mds(self, cluster_id, server_id):
        if not cluster_id:
            raise exc.CommandError('no valid cluster id provided to add pool!')
        return self._create(self.base_url.clusters(cluster_id).servers(server_id).mdses, None)

    def manipulate_mds(self, cluster_id, server_id, mds_id, operation):
        if not cluster_id:
            raise exc.CommandError('no valid cluster id is provided to manipulate mds!')
        if not server_id:
            raise exc.CommandError('no valid server id is provided to manipulate mds!')
        if not mds_id:
            raise exc.CommandError('no valid mds id is provided to manipulate mds!')
        if operation in CAP_OPERATTION:
            entity = {'operation': operation}
        else:
            raise exc.CommandError('Invalid operation on mds: %s!, possilbe value: %s' % (operation, CAP_OPERATTION))
        return self._patch(self.base_url.clusters(cluster_id).servers(server_id).mdses(mds_id), entity)

    def delete_mds(self, cluster_id, server_id, mds_id):
        if not cluster_id:
            raise exc.CommandError('no valid cluster id is provided to delete pool!')
        if not server_id:
            raise exc.CommandError('no valid server id is provided to delete mds!')
        if not mds_id:
            raise exc.CommandError('no valid mds id is provided to delete mds!')
        return self._delete(self.base_url.clusters(cluster_id).servers(server_id).mdses(mds_id))

    def get_hosts_number(self, cluster_id, status=0, **kwargs):
        if not cluster_id:
            raise exc.CommandError('Must provide cluster id!')
        path = "%s/$count" % str(self.base_url.clusters(cluster_id).servers)
        entity = {'status': status}
        entity.update(kwargs)
        return self._get(options.build_url_encoded(path, None, entity))

    def get_cephfses(self, cluster_id):
        if not cluster_id:
            raise exc.CommandError('Must provide cluster id!')
        return self._list(self.base_url.clusters(cluster_id).fses)

    def all_users(self, cluster_id):
        if not cluster_id:
            raise exc.CommandError('Must provide cluster id!')
        return self._list(self.base_url.clusters(cluster_id).users)

    def add_user(self, cluster_id, **kwargs):
        if not cluster_id:
            raise exc.CommandError('Must provide cluster id!')
        entity = {}
        entity.update(kwargs)
        return self._create(self.base_url.clusters(cluster_id).users, entity)

    def delete_user(self, cluster_id, user_id):
        if not cluster_id:
            raise exc.CommandError('Must provide cluster id!')
        self._delete(self.base_url.clusters(cluster_id).users(user_id))

    def add_dir(self, cluster_id, fs_id, **kwargs):
        if not cluster_id:
            raise exc.CommandError('Must provide cluster id!')
        entity = {}
        entity.update(kwargs)
        return self._create(self.base_url.clusters(cluster_id).fses(fs_id).dirs, entity)

    def get_dirs(self, cluster_id, fs_id, path):
        if not cluster_id:
            raise exc.CommandError('Must provide cluster id!')
        if not fs_id:
            raise exc.CommandError('Must provide file system id!')
        if not path:
            raise exc.CommandError('Must provide directory path!')
        query_params = {
            "path": str(path)
        }
        uri_path = str(self.base_url.clusters(cluster_id).fses(fs_id).dirs)
        return self._list(options.build_url_encoded(uri_path, None, query_params))

    def modify_dir(self, cluster_id, fs_id, **kwargs):
        if not cluster_id:
            raise exc.CommandError('Must provide cluster id!')
        if not fs_id:
            raise exc.CommandError('Must provide cephfs id!')
        dir_inode = kwargs.get("inode")
        if not dir_inode:
            raise exc.CommandError('Must provide directory inode')
        entity = {}
        entity.update(kwargs)
        return self._update(self.base_url.clusters(cluster_id).fses(fs_id).dirs(dir_inode), entity)

    def delete_dir(self, cluster_id, fs_id, inode):
        if not cluster_id:
            raise exc.CommandError('Must provide cluster id!')
        if not fs_id:
            raise exc.CommandError('Must provide file system id!')
        if not inode:
            raise exc.CommandError('Must provide directory inode!')
        self._delete(self.base_url.clusters(cluster_id).fses(fs_id).dirs(inode))

    def list_groups(self, cluster_id, underlying=0):
        if not cluster_id:
            raise exc.CommandError('Cluster id should be provided!')
        groups_uri = self.base_url.clusters(cluster_id).groups
        return self._list(options.build_url_encoded(str(groups_uri), None, {"underlying": underlying}))

    def add_group(self, cluster_id, name, max_size='10', leaf_firstn='rack', **kwargs):
        if not cluster_id:
            raise exc.CommandError('no valid cluster id is provided to add group!')
        body = dict(cluster_id=cluster_id, name=name, max_size=max_size, leaf_firstn=leaf_firstn)
        body.update(kwargs)
        return self._create(self.base_url.clusters(cluster_id).groups, body)

    def del_group(self, cluster_id, group_id):
        if not cluster_id:
            raise exc.CommandError('no valid cluster id is provided to delete group!')
        if not group_id:
            raise exc.CommandError('no valid group id is provided to delete group!')
        self._delete(self.base_url.clusters(cluster_id).groups(group_id))

    def rename_group(self, cluster_id, group_id, new_name):
        if not cluster_id:
            raise exc.CommandError('no valid cluster id is provided to modify group!')
        if not group_id:
            raise exc.CommandError('no valid group id is provided to modify group!')
        if not new_name:
            raise exc.CommandError('no new name for group is provided')

        entity = dict(name=new_name)
        return self._update(self.base_url.clusters(cluster_id).groups(group_id), entity)

    def update_group(self, cluster_id, group_id, **kwargs):
        if not cluster_id:
            raise exc.CommandError('no valid cluster id is provided to modify group!')
        if not group_id:
            raise exc.CommandError('no valid group id is provided to modify group!')

        entity = dict()
        entity.update(kwargs)
        if not entity:
            raise exc.CommandError('no valid information is provided to '
                                   'update group %s: %s!' % (cluster_id, group_id))
        return self._patch(self.base_url.clusters(cluster_id).groups(group_id), entity)

    def list_buckets(self, cluster_id, group_id, parent_id):
        if not cluster_id:
            raise exc.CommandError('Cluster id should be provided!')
        if not group_id:
            raise exc.CommandError('Group id should be provided!')
        if parent_id is None:
            parent_id = -1
        buckets_uri = self.base_url.clusters(cluster_id).groups(group_id).buckets
        return self._list(options.build_url_encoded(str(buckets_uri), None, {"parent_id": parent_id}))

    def add_bucket(self, cluster_id, group_id, parent_id, **kwargs):
        if not cluster_id:
            raise exc.CommandError('Cluster id should be provided!')
        if not group_id:
            raise exc.CommandError('Group id should be provided!')
        if parent_id is None:
            parent_id = -1
        kwargs.update({'parent_id': parent_id})
        return self._create(self.base_url.clusters(cluster_id).groups(group_id).buckets, kwargs)

    def move_bucket(self, cluster_id, group_id, bucket_id, parent_id, target_group):
        if not cluster_id:
            raise exc.CommandError('Cluster id should be provided!')
        if not group_id:
            raise exc.CommandError('Group id should be provided!')
        if not bucket_id:
            raise exc.CommandError('Bucket id should be provided!')
        if parent_id is None:
            parent_id = -1
        payload = {
            "parent_id": parent_id,
            "target_group": target_group
        }
        return self._patch(self.base_url.clusters(cluster_id).groups(group_id).buckets(bucket_id), payload)

    def rename_bucket(self, cluster_id, group_id, bucket_id, new_name):
        if not cluster_id:
            raise exc.CommandError('Cluster id should be provided!')
        if not group_id:
            raise exc.CommandError('Group id should be provided!')
        if not bucket_id:
            raise exc.CommandError('Bucket id should be provided!')
        if not new_name:
            raise exc.CommandError('no new name for group is provided')

        entity = dict(name=new_name)
        return self._update(self.base_url.clusters(cluster_id).groups(group_id).buckets(bucket_id), entity)

    def delete_bucket(self, cluster_id, group_id, bucket_id):
        if not cluster_id:
            raise exc.CommandError('Cluster id should be provided!')
        if not group_id:
            raise exc.CommandError('Group id should be provided!')
        if not bucket_id:
            raise exc.CommandError('Bucket id should be provided!')
        return self._delete(self.base_url.clusters(cluster_id).groups(group_id).buckets(bucket_id))

    def update_agent(self):
        return self._post(self.base_url.updateagent, None)

    def get_logs(self, **kwargs):
        return self._get(options.build_url_encoded(str(self.base_url.logs), None, kwargs))

    def get_log_filters(self):
        return self._get(self.base_url.logs.filters)

    def create_log(self, **kwargs):
        return self._create(self.base_url.logs, body=kwargs)

    def get_alerts(self, **kwargs):
        return self._get(options.build_url_encoded(str(self.base_url.alerts), None, kwargs))

    def modify_alert(self, alert_id, **kwargs):
        if alert_id is None:
            raise exc.CommandError('must specify alert id to update!')
        allowed = ["threshold", "period", "status","severity"]
        for key in kwargs.keys():
            if key not in allowed:
                raise exc.CommandError('%s is not a valid parameter' % key)
        entity = dict()
        entity.update(kwargs)
        return self._update(self.base_url.alerts(alert_id), entity)

    def create_alert(self, **kwargs):
        required = ["alerttype_id", "entity_id"]
        allowed = ["threshold", "period", "status", "severity", "description"]

        for item in required:
            if not kwargs.has_key(item):
                raise exc.CommandError('needs to specify %s' % item)

        for key in kwargs.keys():
            if key not in allowed and key not in required:
                raise exc.CommandError('%s is not a valid parameter' % key)
        entity = dict()
        entity.update(kwargs)
        return self._create(self.base_url.alerts, entity)

    def delete_alert(self, alert_id):
        if alert_id is None:
            raise exc.CommandError('must specify mail id to delete!')

        self._delete(self.base_url.alerts(alert_id))

    def get_alerttypes(self):
        return self._list(self.base_url.alerttypes)

    def modify_alerttype(self, alerttype_id, **kwargs):
        if alerttype_id is None:
            raise exc.CommandError('must specify alerttype id to update!')
        allowed = ["default_threshold", "default_period", "default_trapenabled", "default_alertenabled",
                   "default_severity"]
        for key in kwargs.keys():
            if key not in allowed:
                raise exc.CommandError('%s is not a valid parameter' % key)
        entity = dict()
        entity.update(kwargs)
        return self._update(self.base_url.alerttypes(alerttype_id), entity)

    def get_alert_events(self, **kwargs):
        return self._get(options.build_url_encoded(str(self.base_url.alertevents), None, kwargs))

    def get_notification_settings(self):
        return self._get(self.base_url.notification.settings)

    def modify_notification_settings(self, **kwargs):
        if not kwargs:
            raise exc.CommandError('no valid properties provided to update notification settings!')
        entity = dict()
        entity.update(kwargs)
        return self._update(self.base_url.notification.settings, entity)

    def get_emailnotifications(self, **kwargs):
        items = ['enabled',]
        for key in kwargs.keys():
            if key not in items:
                raise exc.CommandError('%s is not a valid parameter' %key)
        entity = dict()
        entity.update(kwargs)
        return self._list(options.build_url_encoded(str(self.base_url.notification.emails), None, entity))

    def modify_emailnotification(self, id, **kwargs):
        if id is None:
            raise exc.CommandError('must specify mail id to update!')
        allowed = ["receiver", "severity_mask", "enabled"]
        for key in kwargs.keys():
            if key not in allowed:
                raise exc.CommandError('%s is not a valid parameter' % key)
        entity = dict()
        entity.update(kwargs)
        return self._update(self.base_url.notification.emails(id), entity)

    def create_emailnotification(self, **kwargs):
        required = ["receiver", "severity_mask", "enabled"]
        for item in required:
            if not kwargs.has_key(item):
                raise exc.CommandError('needs to specify %s' % item)

        entity = dict()
        entity.update(kwargs)
        return self._create(self.base_url.notification.emails, entity)

    def delete_emailnotification(self, id):
        if id is None:
            raise exc.CommandError('must specify mail id to delete!')

        self._delete(self.base_url.notification.emails(id))

    def get_osd_detail(self, cluster_id, server_id, osd_id):
        if not cluster_id:
            raise exc.CommandError('must specify cluster id!')
        if not server_id:
            raise exc.CommandError('must specify server id!')
        if not osd_id:
            raise exc.CommandError('must specify osd id!')
        return self._get(self.base_url.clusters(cluster_id).
                         servers(server_id).osds(osd_id),
                         None,None)
    def get_rbd_detail(self, cluster_id, pool_id, rbd_id):
        if not cluster_id:
            raise exc.CommandError('must specify cluster id!')
        if not pool_id:
            raise exc.CommandError('must specify server id!')
        if not rbd_id:
            raise exc.CommandError('must specify osd id!')
        return self._get(self.base_url.clusters(cluster_id).
                         pools(pool_id).rbds(rbd_id),
                         None,None)

    def get_snmp_conf(self, **kwargs):
        return self._list(self.base_url.snmp.config)
    def set_snmp_conf(self, community_list):
        ''' parameter must be a list like this
        [
        {
            "community": "public",
            "traphostlist": [
                "10.240.217.150",
                "10.240.217.71",
                "10.240.217.119"
            ],
            "gethostlist": [
                "10.240.217.150",
                "10.240.217.72",
                "10.240.217.119"
            ]
        }
        ]
        '''
        if not isinstance(community_list, list):
            raise exc.CommandError('parameter community_list must be a list')
        entity = {'entity': community_list}
        return self._update(self.base_url.snmp.config,entity)


    def get_deferred_rbd_list(self, cluster_id):
        if not cluster_id:
            raise exc.CommandError('Must specify cluster id!')
        return self._list(self.base_url.clusters(cluster_id).deferredrbds,
                          None, None)

    def undo_delay_delete(self, cluster_id, pool_id, rbd_id):
        base_url = "/v1/clusters/"
        url = "%s/%s/pools/%s/rbds/%s/rollback" % (base_url, cluster_id, pool_id, rbd_id)
        return self._update(url, {})

    def get_server_monitors(self, cluster_id, server_id):
        if not cluster_id:
            raise exc.CommandError('Must specify cluster id!')
        if not server_id:
            raise exc.CommandError('Must specify server id!')
        return self._list(self.base_url.clusters(cluster_id).servers(server_id).mons,
                          None, None)

    def add_rb_policy(self, cluster_id, pool_id, **kwargs):
        if cluster_id is None:
            raise exc.CommandError('must specify cluster id to set backup policy')
        if pool_id is None:
            raise exc.CommandError('must specify pool id to set backup policy')

        allowed = ["des_cluster_id", "src_host_id", "des_host_id", "src_ip", "des_ip"]
        for key in kwargs.keys():
            if key not in allowed:
                raise exc.CommandError("%s is not a valid parameter" % key)
        entity = dict()
        entity.update(kwargs)
        return self._create(self.base_url.clusters(cluster_id).pools(pool_id).rbpolicy, entity)

    def delete_rb_policy(self, cluster_id, pool_id):
        if cluster_id is None:
            raise exc.CommandError('must specify cluster id to delete backup policy')
        if pool_id is None:
            raise exc.CommandError('must specify pool id to delete backup policy')

        self._delete(self.base_url.clusters(cluster_id).pools(pool_id).rbpolicy)

    def get_rb_policy(self, cluster_id, pool_id):
        if cluster_id is None:
            raise exc.CommandError('must specify cluster id to query backup policy')
        if pool_id is None:
            raise exc.CommandError('must specify pool id to query backup policy')

        return self._get(self.base_url.clusters(cluster_id).pools(pool_id).rbpolicy)

    def remote_copy(self, cluster_id, pool_id, **data):
        return self._create(self.base_url.clusters(cluster_id).pools(pool_id).rbtask, data)

    def list_remote_copy_tasks(self, cluster_id, pool_id, count, begin_index):
        return self._list("%s?count=%s&begin_index=%s" % (
            str(self.base_url.clusters(cluster_id).pools(pool_id).list_rbtasks), count, begin_index))

    def get_rb_snap_versions(self, cluster_id, pool_id, rbd_id):
        if cluster_id is None:
            raise exc.CommandError('must specify cluster id '
                                   'to query rbd rollback versions')
        if pool_id is None:
            raise exc.CommandError('must specify pool id '
                                   'to query rbd rollback versions')
        if rbd_id is None:
            raise exc.CommandError('must specify rbd id '
                                   'to query rbd roolback versions')

        return self._list(self.base_url.clusters(cluster_id).pools(pool_id)
                          .rbds(rbd_id).backup.snaps)

    def update_rb_snap_versions(self, cluster_id, pool_id, rbd_id, **kwargs):
        if cluster_id is None:
            raise exc.CommandError('must specify cluster id '
                                   'to update rbd rollback versions')
        if pool_id is None:
            raise exc.CommandError('must specify pool id '
                                   'to update rbd rollback versions')
        if rbd_id is None:
            raise exc.CommandError('must specify rbd id '
                                   'to update rbd roolback versions')

        entity = dict()
        entity.update(kwargs)
        return self._update(self.base_url.clusters(cluster_id).pools(pool_id).rbds(rbd_id).backup.snaps, entity)

    def list_backup_rb(self, cluster_id, **kwargs):
        return self._get(options.build_url_encoded(
            str(self.base_url.clusters(cluster_id).backup.rbtasks), None, kwargs))

    def create_backup_rb(self, cluster_id, **kwargs):
        if cluster_id is None:
            raise exc.CommandError('must provide cluster id '
                                   'to create backup rbtask')
        entity = dict()
        entity.update(kwargs)
        return self._create(
            self.base_url.clusters(cluster_id).backup.rbtasks, entity)

    def delete_backup_rb(self, cluster_id, rbtask_id):
        if cluster_id is None:
            raise exc.CommandError('must provide cluster id '
                                   'to delete backup rbtask')
        if rbtask_id is None:
            raise exc.CommandError('must provide rbtask id '
                                   'to delete backup rbtask')
        self._delete(
            self.base_url.clusters(cluster_id).backup.rbtasks(rbtask_id))

    def update_backup_rb(self, cluster_id, rbtask_id, **kwargs):
        if not cluster_id:
            raise exc.CommandError('must provide cluster id '
                                   'to update backup rbtask')
        if not kwargs:
            raise exc.CommandError('must provide properties '
                                   'to update backup rbtask')
        entity = dict()
        entity.update(kwargs)
        return self._update(
            self.base_url.clusters(cluster_id).backup.rbtasks(rbtask_id),
            entity)

    def get_backup_log(self, cluster_id, **kwargs):
        return self._get(options.build_url_encoded(
            str(self.base_url.clusters(cluster_id).backup.logs), None, kwargs))

    def get_backup_pool(self, cluster_id):
        if cluster_id is None:
            raise exc.CommandError('must provide cluster id '
                                   'to get backup pool')

        return self._get(
            self.base_url.clusters(cluster_id).backup.pools)

    # def get_backup_rbd(self, cluster_id, pool_id):
    #     if cluster_id is None:
    #         raise exc.CommandError('must provide cluster id '
    #                                'to delete backup rbtask')
    #     if pool_id is None:
    #         raise exc.CommandError('must provide pool id '
    #                                'to delete backup rbtask')
    #     return self._get(
    #         self.base_url.clusters(cluster_id).pools(pool_id).backup.rbds)


    def rollback_rbd(self, cluster_id, pool_id, rbd_id, **kwargs):
        if cluster_id is None:
            raise exc.CommandError('must provide cluster id to rollback rbd')
        if pool_id is None:
            raise exc.CommandError('must provide pool id to rollback rbd')
        if rbd_id is None:
            raise exc.CommandError('must provide rbd id to rollback rbd')

        entity = {
            'cluster_id': cluster_id,
            'pool_id': pool_id,
            'rbd_id': rbd_id,
        }
        entity.update(kwargs)

        return self._create(self.base_url.backup.restore, entity)

    def add_external_sites(self,**kwargs):
        items = ['site_name','site_type','configuration','keyring','access_key','secret_key','endpoint','region']
        for key in kwargs.keys():
            if key not in items:
                raise exc.CommandError('%s is not a valid parameter' %key)
        entity = dict()
        entity.update(kwargs)
        site = self._create(self.base_url.backup.sites, entity)
        return site

    def get_dest_backup_sites(self, cluster_id):
        if not cluster_id:
           raise exc.CommandError('must specify cluster id to get the destination backup sites')
        return self._list(self.base_url.clusters(cluster_id).backup.sites)

    def get_external_sites(self):
        return self._list(self.base_url.backup.sites)

    def del_external_site(self, site_id):
        if site_id is None:
           raise exc.CommandError('must specify site id to delete!')
        self._delete(self.base_url.backup.sites(site_id))

    def get_external_site_detail(self, site_id, **kwargs):
        if not site_id:
            raise exc.CommandError('must specify site id to get detail!')

        entity = dict()
        entity.update(kwargs)
        return self._get(options.build_url_encoded(str(self.base_url.backup.sites(site_id)), None, entity))

    def modify_external_site(self, site_id, **kwargs):
        if not site_id:
           raise exc.CommandError('must specify site id to modify a backup site')
        items = ['site_name','site_type','configuration','keyring','access_key','secret_key','endpoint','region']
        for key in kwargs.keys():
           if key not in items:
              raise exc.CommandError('%s is not a valid parameter' %key)
        entity = dict()
        entity.update(kwargs)
        return self._update(self.base_url.backup.sites(site_id), entity)

    def external_site_connection_check(self, site_id, **kwargs):
        if not site_id:
            raise exc.CommandError('must specify site id to get detail!')
        entity = dict()
        entity.update(kwargs)
        return self._update(self.base_url.backup.sites(site_id).connection, entity)

    def add_rack(self, cluster_id, group_id, **kwargs):
        entity = dict((key, value) for (key, value) in kwargs.items())
        if not entity:
            raise exc.CommandError('no valid information is provided to '
                                   'add rack to group %s: %s!' % (group_id, kwargs))
        return self._create(self.base_url.clusters(cluster_id).groups(group_id).racks, entity)

    def list_racks(self, cluster_id, group_id, **kwargs):
        return self._list(self.base_url.clusters(cluster_id).groups(group_id).racks)
        
    def get_license(self):
        return self._list(self.base_url.license)

    def decode_license(self, **kwargs):
        entity = dict()
        entity.update(kwargs) 
        return self._update(self.base_url.license, entity)

    def submit_license(self, **kwargs):
        entity = dict()
        entity.update(kwargs)
        return self._create(self.base_url.license, entity)
