#!/bin/sh
stack=$(openstack stack list --nested | grep -i fail |awk  -F '|' '{print $3}' |head -n 1)
echo "Failed: $stack"
physical_ids=$(openstack stack resource list -c physical_resource_id  -f value $(openstack stack list --nested | grep -i fail |awk  -F '|' '{print $3}' |head -n 1))
openstack stack resource list $(openstack stack list --nested | grep -i fail |awk  -F '|' '{print $3}' |head -n 1)
for physical_id in $physical_ids;do echo " physical id: $physical_id";openstack software deployment show $physical_id;openstack software deployment output show $physical_id --all --long;done

