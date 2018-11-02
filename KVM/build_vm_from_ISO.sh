#!/bin/bash

######################################
#all configuration of this script
######################################

vm_name="lt-rhel2"
ISO_file="/mnt/raid0_disk/vsftpd/iso/RHEL/rhel-server-7.5-x86_64-dvd.iso"
ks_file=$1

Bridge_Name="br0"
Net_name1="leo_manage"

##################
#for 71 server
##################
#OS_disk_path="/mnt/sde/KVM/libvirt"

##################
#for 72 server
##################
OS_disk_path="/mnt/raid0_disk/leo/KVM/test"




######################################
#check return value of last command
######################################

function check_return()
{
    ret=$?
    if [ $ret -ne 0 ];then
        echo -e "\033[47;31mfailed: exit on $0:$1 [return:$ret]\033[0m"
        if [ ! -z "$2" ];then
            echo -e "\033[47;31m[$2]\033[0m"
        fi
        exit $ret
    fi
}


######################################
#install vm
######################################

##
vcpus=4
memory=4096
disk_size=512

##
virt-install \
    --name ${vm_name} \
    --vcpus ${vcpus} \
    --cpu "host-passthrough" \
    --memory ${memory} \
    --location ${ISO_file} \
    --os-variant "rhel7" \
    --disk path=${OS_disk_path}/${vm_name}.img,format=qcow2,size=${disk_size},bus=virtio,cache=writeback \
    --network bridge=${Bridge_Name},model=rtl8139 \
    --network network=${Net_name1},model=rtl8139 \
    --noautoconsole \
    --hvm \
    --initrd-inject=${ks_file} --extra-args "ks=file:/ks.cfg"
check_return $LINENO
    #--boot hd \
    #--location ${ISO_file} \
