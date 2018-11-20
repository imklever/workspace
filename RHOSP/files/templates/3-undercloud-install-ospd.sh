#!/usr/bin/env bash
# after reboot
# run as STACK user su - stack
# clone this repo into your stack user's home directory, then run this script.

# are we root?  that's bad
if [[ $EUID -eq 0 ]]; then
  echo "Do not run as root; su - stack" 2>&1
  exit 1
fi

# we store files in git that need to be in the
# stack users home directory, fetch them out
#cp ~/rhosp_cloud6/stack-home/undercloud.conf ~

# Install openstack undercloud
cd ~
openstack undercloud install
source ~/stackrc

# get images, upload to undercloud
sudo sudo yum -y install rhosp-director-images rhosp-director-images-ipa
mkdir ~/images
cd ~/images
for i in /usr/share/rhosp-director-images/overcloud-full-latest-13.0.tar \
  /usr/share/rhosp-director-images/ironic-python-agent-latest-13.0.tar; \
  do tar -xvf $i; done
openstack overcloud image upload --image-path /home/stack/images


# create flavors for overcloud
 for i in virtual-compute x3650-compute dpdkcompute; do
  openstack flavor create --id auto --ram 1 --disk 40 --vcpus 1 $i;
  openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="$i" $i;
 done

openstack subnet set --dns-nameserver 10.240.0.10 --dns-nameserver 10.240.0.11 ctlplane-subnet

# import hardware, configure boot and introspect
openstack overcloud node import ~/rhosp-cloud6/stack-home/instackenv.json
openstack overcloud node introspect --all-manageable --provide

