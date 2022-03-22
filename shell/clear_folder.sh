#! /bin/bash
export HADOOP_USER_NAME=ymmarsza

source=$1
#hdfs://nameservice1/user/ymmarsza/prod

echo 'start clearing'

hadoop fs -rm -R source

echo 'finished clearing'
