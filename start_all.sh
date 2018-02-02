#!/bin/bash
#
# Start all services and run an application
# Heavely dependent of docker-swarm

project_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#Check existence of all required programs
command -v docker > /dev/null || { echo "docker is required... aborting"; exit 2; }
#command -v docker-machine > /dev/null || { echo "docker-machine is required... aborting"; exit 2; }
command -v dsh > /dev/null || { echo "dsh is required... aborting"; exit 2; }

echo "*********************************************"
echo "All set and ready, let's rock!"
echo "*********************************************"

master_machine=$(hostname)
swarm_machines=$(cat ~/.dsh/machines.list)

echo "*********************************************"
echo "Erasing HDFS"
echo "*********************************************"

dsh -aM -c "if [ -f "$project_dir"/hadoop/hadoop_hdfs/datanode/in_use.lock ]; then 
  rm -rf $project_dir/hadoop/hadoop_hdfs/*; fi && 
  awk 'END{ print NR}' ~/.dsh/machines.list > $project_dir/hadoop/hadoop_volume/machines"

echo "*********************************************"
echo "Building images in all nodes in the swarm... grab a coffee this may take a while..." 
echo "*********************************************"
 
dsh -aM -c "docker build -t hadoop "$project_dir/hadoop"; \
  docker build -t spark "$project_dir/spark"; \
  docker build -t application "$project_dir/application""

echo "*********************************************"
echo "Ready to build the app... standby"
echo "*********************************************"

docker stack deploy -c "$project_dir"/docker-compose.yml hadoop_test

