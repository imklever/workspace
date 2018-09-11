file_list="
/etc/openstack-dashboard/local_settings
/usr/lib/python2.7/site-packages/cephmgmtclient/v1/cephstorages.py

/usr/lib/python2.7/site-packages/storagemgmt/common/base.py
/usr/lib/python2.7/site-packages/storagemgmt/common/zabbix_util.py
/usr/lib/python2.7/site-packages/storagemgmt/common/zab_client.py
/usr/lib/python2.7/site-packages/storagemgmt/common/kpifactory/__init__.py
/usr/lib/python2.7/site-packages/storagemgmt/common/kpifactory/ceph_cluster.py
/usr/lib/python2.7/site-packages/storagemgmt/common/kpifactory/kpi.py
/usr/lib/python2.7/site-packages/storagemgmt/common/timeutil.py
"
for i in $file_list
do
    echo $i
    scp 10.240.217.116:$i ./
done
