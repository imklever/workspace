#!/usr/bin/env bash
source ~/stackrc

openstack overcloud container image prepare \
  --namespace=registry.access.redhat.com/rhosp13 \
  --push-destination=172.30.5.1:8787 \
  --prefix=openstack- \
  -e /usr/share/openstack-tripleo-heat-templates/environments/ceph-ansible/ceph-ansible.yaml \
  --set ceph_namespace=registry.access.redhat.com/rhceph \
  --set ceph_image=rhceph-3-rhel7 \
  --tag-from-label {version}-{release} \
  --output-env-file=/home/stack/templates/overcloud_images.yaml \
  --output-images-file /home/stack/local_registry_images.yaml
  --verbose

sudo openstack overcloud container image upload \
  --config-file  /home/stack/local_registry_images.yaml \
  --verbose

# view registry images:
# curl -X GET http://172.30.6.1:8787/v2/_catalog | jq

# view tags of a specific image:
# curl -X GET http://172.30.6.1:8787/v2/rhosp13/openstack-nova-api/tags/list

