#!/bin/bash
source ~/stackrc
openstack overcloud deploy --templates \
  -p /home/stack/templates/plan-environment-derived-params.yaml \
  -r /home/stack/templates/roles_data.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/ceph-ansible/ceph-ansible.yaml \
  -e /home/stack/templates/storage-config.yaml \
  -e /home/stack/templates/storage-container-config.yaml \
  -e /home/stack/templates/network-environment.yaml \
  -e /home/stack/templates/overcloud_images_sa.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/ssl/inject-trust-anchor.yaml \
  --ntp-server cn.ntp.org.cn
