rados_t cluster;
rados_ioctx_t ioctx;
rados_create(&cluster,null)
rados_conf_read_file(cluster,null)
rados_connect(cluster)
rados_ioctx_create(cluster,pool_name.c_str(), &ioctx)
rados_write(ioctcx, "foo", buf,sizeof(buf))

these are steps of using librados:
step1. create a RadosClient object.
step2. read the config file.
step3. connect cluster.
step4. create an IoCtxImpl object.
step5. write the data to the pool.

in step4 an IoCtxImpl object means a set of info about a pool. Which means every pool has it's own IoCtxImpl object

lass Objecter : public md_config_obs_t, public Dispatcher {
