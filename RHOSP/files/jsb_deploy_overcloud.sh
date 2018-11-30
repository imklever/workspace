#!/bin/bash
source ~/stackrc
# should probably back up the original file first
#sudo cp /usr/share/openstack-tripleo-heat-templates/network_data.yaml ~/rhosp-cloud5/templates/network_data.yaml.origin
#sudo cp ~/lj_templates/network_data.yaml /usr/share/openstack-tripleo-heat-templates/

cd /usr/share/openstack-tripleo-heat-templates
sudo ./tools/process-templates.py -r /home/stack/jsb_templates/roles_data.yaml -n /home/stack/jsb_templates/network_data.yaml

cd /home/stack
openstack overcloud deploy --answers-file ~/jsb_templates/answers.yaml \
  --ntp-server cn.pool.ntp.org
