#### Introduction

Puppet Labs’ [Open Source](http://puppetlabs.com/puppet/puppet-open-source) Puppet Agent/Master architecture is an effective solution to manage infrastructure and system configuration. However, for the average System Engineer or Software Developer, installing and configuring Puppet Master and Puppet Agent can be challenging. If the installation doesn’t work properly, the engineer’s stuck troubleshooting, or trying to remove and re-install Puppet.

A better solution, automate the installation of Puppet Master and Puppet Agent on Virtual Machines (VMs). Automating the installation process guarantees accuracy and consistency. Installing Puppet on VMs means the VMs can be snapshotted, cloned, or simply destroyed and recreated, if needed.

In this post, we will use [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/) to create three VMs. The VMs will be build from a [CentOS 7](https://www.centos.org/) Vagrant Box, previously on Vagrant Cloud, now on [Atlas](https://atlas.hashicorp.com/centos/boxes/7). We will use a single JSON-format configuration file to build all three VMs, automatically. As part of the Vagrant provisioning process, we will run a bootstrap shell script to install Puppet Master on the first VM (Puppet Master server) and Puppet Agent on the two remaining VMs (agent nodes).

Lastly, to test our Puppet installations, we will use Puppet to install some basic Puppet modules, including [ntp](https://forge.puppetlabs.com/puppetlabs/ntp) and [git](https://forge.puppetlabs.com/puppetlabs/git) on the server, and [ntp](https://forge.puppetlabs.com/puppetlabs/ntp), [git](https://forge.puppetlabs.com/puppetlabs/git), [Docker](https://www.docker.com/) and [Fig](http://www.fig.sh/), on the [agent nodes](https://docs.puppetlabs.com/references/glossary.html#node-definition).

All the source code this project is on [Github](https://github.com/ehime/vagrant-cluster).
