#!/bin/sh

    state=$(openstack baremetal node list|grep cloud |awk  -F '|' '{print $5}' |sed 's/^[ \t]*\|[ \t]*//g') 
    state=(${state// / })
    name=$(openstack baremetal node list|grep cloud |awk  -F '|' '{print $3}' |sed 's/^[ \t]*\|[ \t]*$//g')
    name=(${name// / })
    for(( i=0;i<${#state[@]};i++)) 
    do 
       echo ${state[i]}
       echo ${name[i]}
       if [ "${name[i]}" == "cloud2-contorller" ]; then
         name[i]="cloud2-controller"
       fi
       ansible-playbook  -e "vm_name=${name[i]}" stop_vm.yaml &
       echo "Compute power off"
    done;
