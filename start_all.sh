#!/bin/bash
#
# Start all services and run an application
# Heavely dependent of docker-swarm

project_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#Check existence of all required programs
command -v docker > /dev/null || { echo "docker is required... aborting"; exit 2; }
command -v docker-machine > /dev/null || { echo "docker-machine is required... aborting"; exit 2; }

echo "*********************************************"
echo "All set and ready, let's rock!"
echo "*********************************************"

master_machine=$(docker-machine ls | awk 'NR == 2 {print $1}')
eval $(docker-machine env "$master_machine")
swarm_machines=$(docker node ls | awk 'NR != 1 {if ($2 != "*") {print $2} else {print $3}}')
echo "$swarm_machines" > "$project_dir"/hadoop/hadoop_conf/slaves

# In a real distributed scenario a tool like DSH is required. In a test environment, building is performed via docker-machine
echo "*********************************************"
echo "Building images in all nodes in the swarm... grab a coffee this may take a while..." 
echo "*********************************************"
for node in $swarm_machines; do
  echo "*********************************************"
  echo "Machine: $node"
  echo "*********************************************"
  eval $(docker-machine env "$node")
  #docker rmi -f $(docker images -q)
  docker build -t alejandromontero/hadoop:latest "$project_dir/hadoop"
  docker build -t alejandromontero/spark:latest "$project_dir/spark"
  docker build -t alejandromontero/application:latest "$project_dir/application"
done
eval $(docker-machine env "$master_machine")
echo "*********************************************"
echo "Ready to build the app... standby"
echo "*********************************************"

