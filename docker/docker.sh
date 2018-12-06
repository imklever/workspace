

docker ps | awk '{print $NF}' | sed '1d' | sort

for i in `docker ps | awk '{print $NF}' | sed '1d' | sort`; do echo $i;docker inspect $i | grep Network; done
for i in `docker ps | awk '{print $NF}' | sed '1d' | sort`; do echo $i;docker inspect $i | grep NetworkMode; done

for i in `docker ps | awk '{print $NF}' | sed '1d' | sort`; do echo $i;read var; docker exec -ti $i ifconfig; done
