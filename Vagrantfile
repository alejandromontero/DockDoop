#on previous versions it does not download the VM image automatically
Vagrant.require_version ">= 1.6"

VAGRANTFILE_API_VERSION = "2"

# defaults for cluster
numberOfNodes = 2
vmRAM = 3096
vmCPUS = 2
sshKeyPath = "../keys/id_rsa"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "ubuntu/trusty64"
  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 2
  end
  config.vm.network "private_network", type: "dhcp"

  # Provision Config for each of the nodes
  0.upto(numberOfNodes) do |i|
    config.vm.define vm_name = "node#{i}" do |config|
      config.vm.hostname = vm_name
      ip = "192.168.0.#{100+i}"
      config.vm.network "private_network",
        ip: ip,
        virtualbox__intnet: "clusternet"
      #config.ssh.private_key_path = File.expand_path(sshKeyPath, __FILE__)
    end
  end
  config.vm.provision "shell", :path => "./vagrant_deploy.sh", :args =>  numberOfNodes, :binary=> false
end
