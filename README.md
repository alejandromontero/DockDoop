# DockDoop
Utiility to deploy a containerized Hadoop Ecosystem application using Docker-Swarm.
This utility serves as a template for executing Hadoop or Spark applications and as
baseline to add new engines and applications.

## Table of Contents

- [Install](#install)
- [Usage](#usage)
	- [(OPTIONAL) Start the virtual environment](#virtual-environment)
	- [Initialize the docker-swarm](#initialize-docker-swarm)
	- [Start the application](#start-the-application)
	- [Check application logs](#check-application-logs)
- [Configuration](#Configuration)
- [Development](#Development)
	- [Provide a new Hadoop or Spark application](#provide-a-new-Hadoop-or-Spark-application)
	- [Add a new engine](#add-a-new-engine)

## Install
Make sure you install the prerequisites first.

- [Docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/#upgrade-docker-after-using-the-convenience-script)
- [DSH](https://www.tecmint.com/using-dsh-distributed-shell-to-run-linux-commands-across-multiple-machines/)
- [VirtualBox](https://www.virtualbox.org/)
- [Vagrant](https://www.vagrantup.com/)

The code of this project requires to be distributed across your whole cluster, for that reason you need to clone this repository in a distributed fashion
```
dsh -aM "git clone https://github.com/alejandromontero/hadoop_ecosystem_docker"
```
## Usage
There are two ways to run this project (I) in a virtualized environment for testing purposes, (II) in a real distributed cluster. However, most of the steps are common in both approaches.

### (OPTIONAL) Start the virtual environment 

A virtualized environment is provided for testing purposes. The variable `numberOfNodes` inside the `Vagrantfile` 
defines the number of nodes to create. By default a 3 node cluster will be created.

With `VirtualBox` and `Vagrant` installed run in the project home folder:

```
vagrant up
vagrant ssh node0
```
### Initialize the docker-swarm
If the environment is already configured with `docker` and `dsh` the project is almost ready to run, however the swarm still needs to be initialized. 
To do so, run the following instructions inside the master node:

```
docker swarm init --advertise-addr <vm_addr>
dsh -aM "docker swarm join <token>
```
### Start the application

To run the stack just execute the following script:

```
bash /vagrant/start_all.sh
```
All the images are built in a distributed fashion and require some time to be ready, take a coffee and relax.
### Check application logs

Docker logs can be used to test whether the application works. In the master node run the following instruction to get
the list of running containers:

```
docker container ls
```
Check the number of alive `DataNodes` by running: 

```
docker exec <namenode_ID> hdfs dfsadmin -report
-------------------------------------------------
Live datanodes (2):
```
Check the `Resourcemanager` by running:
```
docker exec <resourcemanager_ID> yarn node -list
Total Nodes:2
         Node-Id             Node-State Node-Http-Address       Number-of-Running-Containers
99567141673f:42427              RUNNING 99567141673f:8042                                  0
1663d8962ba5:47410              RUNNING 1663d8962ba5:8042                                  0
```
Check the application log by running:

```
docker logs <application_ID>
18/02/05 14:28:20 INFO scheduler.DAGScheduler: Job 0 finished: reduce at SparkPi.scala:38, took 9.032237 s
Pi is roughly 3.1419543141954316
```
## Configuration
Each engine has a default configuration available in `$engine/$engine_conf`. Any changes made in the configuration will be used in the next application deployment.
However, it is required to distribute the changes across the whole cluster. A proposed way to do it is to run the next commands from inside the configuration folder:

```
for file in $CONFIG_FOLDER/*; do
  changes=$(cat "$file")
  dsh -aM "$changes > $CONFIG_FOLDER/$file"
done
```
## Development
This project serves as a template for future development. If you need to run a Hadoop or Spark application you are almost completely setted up. In case you require a new engine you will need to create a new Dockerfile and the initializetion bootstap 

### Provide a new Hadoop or Spark application
To run a new application using Hadoop M/R or Spark you only need to change the example code provided in `DockDoop/application/wrapper.sh`. This file is the entrypoint of your application, and can call any Hadoop or Spark binary. Some important notes to consider:

- The local folder `DockDoop/application/app_volume` is shared to the container in `/app/app_volume`. This folder is extremlly useful to provide data or retrieve results from the application
- Hadoop binaries are available at `$HADOOP_HOME/bin`
- Spark binaries are available at `$SPARK_HOME/bin`
- HDFS will be completely erased after completing the application.

### Add a new engine
When adding a new engine you need to follow some advices:

1. All engines have a folder with the name of the engine, without specifying the version to use.
2. Every engine folder contains a Dockerfile to build the image of the engine.
	- The version of the engine needs to be parametrized with an ARGS clause to allow easy changes in the versioning. 
	- All images have to be built from the hadoop image if there is not a stronger image dependency.
3. A shared folder between the local file-system and docker is required with the name `$engine_voluime`.
4. A `bootstrapp.sh` file is required to manage the initialization of the engines and the daemons.
	- A testing deployment is required to test the engine. The `standalone` deployment initializes all other required engine daemons that are dependent for the testing.
5. The application needs to be changed to use the new engine. 
	- Potentially the `FROM` clause needs to point to the new created engine image.
	- The `wrapper` script needs to be modified [Provide a new Hadoop or Spark application](#provide-a-new-Hadoop-or-Spark-application)
6. The `docker-compose.yml` need to deploy the new services(daemons) for the new engine.
