#### Introduction

Puppet Labs’ [Open Source](http://puppetlabs.com/puppet/puppet-open-source) Puppet Agent/Master architecture is an effective solution to manage infrastructure and system configuration. However, for the average System Engineer or Software Developer, installing and configuring Puppet Master and Puppet Agent can be challenging. If the installation doesn’t work properly, the engineer’s stuck troubleshooting, or trying to remove and re-install Puppet.

A better solution, automate the installation of Puppet Master and Puppet Agent on Virtual Machines (VMs). Automating the installation process guarantees accuracy and consistency. Installing Puppet on VMs means the VMs can be snapshotted, cloned, or simply destroyed and recreated, if needed.

In this post, we will use [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/) to create three VMs. The VMs will be build from a [CentOS 7](https://www.centos.org/) Vagrant Box, previously on Vagrant Cloud, now on [Atlas](https://atlas.hashicorp.com/centos/boxes/7). We will use a single JSON-format configuration file to build all three VMs, automatically. As part of the Vagrant provisioning process, we will run a bootstrap shell script to install Puppet Master on the first VM (Puppet Master server) and Puppet Agent on the two remaining VMs (agent nodes).

Lastly, to test our Puppet installations, we will use Puppet to install some basic Puppet modules, including [ntp](https://forge.puppetlabs.com/puppetlabs/ntp) and [git](https://forge.puppetlabs.com/puppetlabs/git) on the server, and [ntp](https://forge.puppetlabs.com/puppetlabs/ntp), [git](https://forge.puppetlabs.com/puppetlabs/git), [Docker](https://www.docker.com/) and [Fig](http://www.fig.sh/), on the [agent nodes](https://docs.puppetlabs.com/references/glossary.html#node-definition).

All the source code this project is on [Github](https://github.com/ehime/vagrant-cluster).


#### Usage

    git clone https://github.com/ehime/vagrant-cluster.git
    vagrant up

##### Generating certs on the Master

    vagrant ssh puppet.mheducation.com
    sudo service puppetmaster status # test that puppet master was installed
    sudo service puppetmaster stop
    sudo puppet master --verbose --no-daemonize # Then:  Ctrl+C to kill puppet master
    sudo service puppetmaster start
    sudo puppet cert list --all # check for 'puppet' cert

  According to [Puppet’s website](https://docs.puppetlabs.com/guides/install_puppet/post_install.html), ‘these steps will create the CA certificate and the puppet master certificate, with the appropriate DNS names included.‘

##### Signing certs for the Nodes

  Now that the Puppet Master server is running, open a second terminal tab (‘Shift+Ctrl+T‘)

    vagrant ssh node01.mheducation.com
    sudo service puppet status # test that agent was installed
    sudo puppet agent --test --waitforcert=60 # initiate certificate signing request (CSR)

    vagrant ssh node02.mheducation.com
    sudo service puppet status # test that agent was installed
    sudo puppet agent --test --waitforcert=60 # initiate certificate signing request (CSR)

##### Accepting certificates on the Master

    sudo puppet cert list # should see 'node01.mheducation.com' cert waiting for signature
    sudo puppet cert sign --all # sign the agent node certs
    sudo puppet cert list --all # check for signed certs



#### NOTES

  If you are having issues with `Vagrant Error: Connection timeout. Retrying....` try adding the following to your `~/.ssh/config`

    Host *
      GSSAPIAuthentication no
