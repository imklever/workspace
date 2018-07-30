pool_name_list="test_pool"


echo "#######################################"
for pool_name in $pool_name_list
do
	echo "---------------------------------------"
	echo -e "\033[32m image list:\033[0m"
	rados lspools
	echo "---------------------------------------"
	rados rmpool ${pool_name} ${pool_name} --yes-i-really-really-mean-it
	echo -e "\033[32m image list:\033[0m"
	rados lspools
done
echo "#######################################"
