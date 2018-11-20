#!/bin/sh

while true
do
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
       if [ "${state[i]}" == "poweron" ]; then
         ansible-playbook  -e "vm_name=${name[i]}" start_vm.yaml &
       else
         echo "Compute power off"
       fi
    done;
    sleep 15 
done
