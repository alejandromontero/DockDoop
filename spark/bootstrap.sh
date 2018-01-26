#!/bin/bash

sed -i s/##HOSTNAME##/"$HOSTNAME"/ "$HADOOP_HOME"/etc/hadoop/*
service ssh start

if [ "$1" == "standalone" ]; then
  echo "Starting Hadoop Services (yarn and HDFS)"
  sed -i s/namenodehost/"$HOSTNAME"/ "$HADOOP_HOME"/etc/hadoop/*
  $HADOOP_HOME/bin/hdfs namenode -format
  $HADOOP_HOME/sbin/start-dfs.sh
  $HADOOP_HOME/sbin/start-yarn.sh
  echo "**************************"
  echo "Starting Spark-shell"
  echo "**************************"
  $SPARK_HOME/bin/spark-shell
else
  echo "Executing "$@""
  "$@"
fi
