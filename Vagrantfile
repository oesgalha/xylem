# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'ubuntu/trusty64'
  config.vm.network :private_network, ip: "192.168.33.78"
  config.vm.synced_folder '.', '/vagrant', nfs: true
  config.ssh.forward_agent = true
  config.vm.define "xylem_develop" do |xylem_develop|
  end
  config.vm.provision :shell, path: 'bootstrap.sh', keep_color: true
end
