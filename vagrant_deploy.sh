#!/bin/bash
#
# Deployment script for provisioning a Vagrant cluster with dsh and docker

if [ ! -f /home/vagrant/provisioned ]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  apt-key fingerprint 0EBFCD88
  add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
  apt-get update
  apt-get install -y dsh \
	             docker-ce
  
  usermod -aG docker vagrant  
  mkdir -p /home/vagrant/.dsh
  sed -i s/rsh/ssh/ /etc/dsh/dsh.conf
  
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  for (( i=0; i <= $1; i++ )) do
    ip="192.168.0.$(( 100+i ))"
    echo "$ip" "node$i" >> /etc/hosts
    echo "node$i" >> /home/vagrant/.dsh/machines.list
  done

  # Copy private keys for passwordless ssh

  install -m 600 -o vagrant -g vagrant /vagrant/hadoop/keys/id_rsa /home/vagrant/.ssh
  install -m 600 -o vagrant -g vagrant /vagrant/hadoop/keys/id_rsa.pub /home/vagrant/.ssh
  cat /vagrant/hadoop/keys/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
fi
