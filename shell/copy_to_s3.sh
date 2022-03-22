#! /bin/bash
export HADOOP_USER_NAME=ymmarsza

source=$1
#hdfs://nameservice1/user/ymmarsza/prod

destination=$2
#s3a://ess-mock-dumps/test

storepath=$3
#jceks:///user/ymmarsza/store/ceph.jceks

endpoint=$4
#https://s3.cloud.cyfronet.pl

echo 'start copying'

hadoop distcp -Dfs.s3a.endpoint=$endpoint -Dhadoop.security.credential.provider.path=$storepath $source $destination

echo 'finished copying'
