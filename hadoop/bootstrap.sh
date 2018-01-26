#!/bin/bash

#Modify the initial templates
sed -i s/##HOSTNAME##/"$HOSTNAME"/ "$HADOOP_HOME"/etc/hadoop/*
service ssh start

if [ "$1" == "yarn" ]; then
  echo "Starting yarn ResourceManager"
  "$HADOOP_HOME"/sbin/start-yarn.sh
  docker node ls | awk '{print}'
  while true; do sleep 10000; done
elif [ "$1" == "namenode" ]; then
  echo "Starting NameNode"
  "$HADOOP_HOME"/bin/hdfs namenode -format
  "$HADOOP_HOME"/sbin/start-dfs.sh
  "$HADOOP_HOME"/sbin/mr-jobhistory-daemon.sh start historyserver
  while true; do sleep 10000; done
elif [ "$1" == "datanode" ]; then
  while true; do sleep 10000; done
elif [ "$1" == "standalone" ]; then 
  echo "Starting Hadoop Services (yarn and HDFS)"
  sed -i s/namenodehost/"$HOSTNAME"/ "$HADOOP_HOME"/etc/hadoop/*
  sed -i s/resourcemanagerhost/"$HOSTNAME"/ "$HADOOP_HOME"/etc/hadoop/*
  "$HADOOP_HOME"/bin/hdfs namenode -format
  "$HADOOP_HOME"/sbin/start-dfs.sh
  "$HADOOP_HOME"/sbin/start-yarn.sh
  echo "*******************************"
  echo "Test1: printing Hadoop Version"
  echo "*******************************"
  "$HADOOP_HOME"/bin/hadoop version
  echo "*******************************"
  echo "Test2: copying text file to HDFS"
  echo "*******************************"
  "$HADOOP_HOME"/bin/hadoop fs -copyFromLocal $HADOOP_HOME/hdfs_test.txt /
  echo "*******************************"
  echo "Test3: read text file from HDFS"
  echo "*******************************"
  "$HADOOP_HOME"/bin/hadoop fs -cat /hdfs_test.txt

  /bin/bash
else
  echo "Running "$@""
  "$@"
fi  
