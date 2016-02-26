# vi: set ft=ruby :
# Builds Puppet Master and multiple Puppet Agent Nodes using JSON config file
# Requires triggers, vagrant plugin install vagrant-triggers
# Requires vbguest,  vagrant plugin install vagrant-vbguest

class GuestFix < VagrantVbguest::Installers::Linux
  def install(opts=nil, &block)
    communicate.sudo('yum update  -y', opts, &block)
    communicate.sudo('yum remove  -y virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11', opts, &block)
    communicate.sudo('yum install -y gcc kernel-devel make', opts, &block)

    ## REF: http://stackoverflow.com/questions/28328775/virtualbox-mount-vboxsf-mounting-failed-with-the-error-no-such-device
#    communicate.sudo('modprobe -a vboxguest vboxsf vboxvideo', opts, &block)
    super
    communicate.sudo('( [ -d /opt/VBoxGuestAdditions-5.0.14/lib/VBoxGuestAdditions ] && sudo ln -s /opt/VBoxGuestAdditions-5.0.14/lib/VBoxGuestAdditions /usr/lib/VBoxGuestAdditions ) || true', )
  end
end

# read vm and chef configurations from JSON files
nodes_config = (JSON.parse(File.read("config/cluster.json")))['nodes']

Vagrant.configure(2) do | config |
  config.vbguest.installer = GuestFix

  # set auto_update to true to check the correct
  # additions version when booting the machine
  config.vbguest.auto_update = true
  config.vbguest.auto_reboot = true

  config.vm.box = "bento/centos-7.1"
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope  = :box
    config.cache.enable   :yum
    config.cache.enable   :puppet
  end

  # List with `vagrant status`
  nodes_config.each do | node |
    node_name   = node[0] # name of node
    node_values = node[1] # content of node

    config.vm.define node_name do | config |

      # configure all forward ports from JSON
      config.ssh.forward_agent = true

      ports = node_values['ports']
      ports.each do | port |
        config.vm.network :forwarded_port,
          host:  port[':host'],
          guest: port[':guest'],
          id:    port[':id']
      end

      config.vm.hostname = node_name

      config.vm.network :private_network,
        ip: node_values[':ip'],
        auto_config: false

      config.vm.provider :virtualbox do | vb |
        vb.customize ["modifyvm", :id, "--memory",  node_values[':memory']]
        vb.customize ["modifyvm", :id, "--name",    node_name]
        #vb.gui = true
      end

      config.vm.provision :shell, :path => node_values[':bootstrap']
    end
  end
end
