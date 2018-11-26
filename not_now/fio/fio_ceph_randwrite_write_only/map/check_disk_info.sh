#!/bin/bash

_disk_list="sda sdb sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn"

for disk in $_disk_list
do
    hdparm -I /dev/${disk} | grep "Model Number"
done
