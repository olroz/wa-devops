# -*- mode: ruby -*-
# vi: set ft=ruby :

db_num_host=3
db_name_prefix="nats"

Vagrant.configure("2") do |config|
  config.trigger.before :up do |trigger|
    trigger.name = "Debugger printer"
    trigger.warn = "Going to create #{db_num_host} - #{db_num_host} Nats instances"
  end
  (1..db_num_host).each do |i|
    config.vm.define "#{db_name_prefix}-#{i}" do |node|

      node.vm.network "private_network", ip: "192.168.50.#{i + 1}"
      node.vm.box = "ubuntu/focal64"
      node.vm.box_version = "20201210.0.0"
      node.vm.provision "shell", path: "script.sh"
      config.trigger.after :up,
        name: "Finished Message",
        info: "hello I'm #{db_name_prefix}-#{i} with 192.168.50.#{i + 1}"
      node.vm.provider "virtualbox" do |v|
        v.memory = 1024
        v.cpus = 1
      end
    end
  end
end
