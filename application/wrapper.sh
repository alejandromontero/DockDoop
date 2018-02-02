#!/bin/bash
#
# Wrapper example to run an application in a swarm

sleep 20
"$SPARK_HOME"/bin/spark-submit \
  --class org.apache.spark.examples.SparkPi \
  "$SPARK_HOME"/examples/jars/spark-examples_*.jar \
  100 

exit 0
