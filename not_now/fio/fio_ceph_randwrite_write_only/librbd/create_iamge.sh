pool_name="test_pool"
image_name="test_image0"
pg_num="2200"

echo "#######################################"
ceph osd pool create ${pool_name} $pg_num $pg_num
echo -e "\033[32m pool list:\033[0m "
rados lspools
echo "---------------------------------------"

ceph osd pool get ${pool_name} pg_num
ceph osd pool get ${pool_name} pgp_num

ceph osd pool application enable ${pool_name} rbd

sleep 10
echo "---------------------------------------"
rbd create ${pool_name}/${image_name} --size=102400 --image-format 2
echo -e "\033[32m image list:\033[0m "
rbd ls ${pool_name}
echo "#######################################"
