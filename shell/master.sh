#!/bin/sh

# Run on VM to bootstrap Puppet Master server
if ps aux | grep "puppet master" | grep -v grep 2> /dev/null
then
    echo "Puppet Master is already installed. Exiting..."
else
    cd /tmp

    # Install Ruby, Required Packages
    sudo yum install -y gcc-c++ patch readline readline-devel zlib zlib-devel
    sudo yum install -y libyaml-devel libffi-devel openssl-devel make
    sudo yum install -y bzip2 autoconf automake libtool bison iconv-devel sqlite-devel

    # Install Ruby, RVM
    curl -sSL https://rvm.io/mpapis.asc | gpg --import -
    curl -L get.rvm.io | bash -s stable
    source /etc/profile.d/rvm.sh
    rvm reload

    # Install Ruby, Test Requirements then install
    rvm requirements run
    rvm install 2.2.4

    # Install Puppet Master
    sudo yum -y install https://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm && \
    sudo yum update --quiet -y && sudo yum upgrade --quiet -y &&                         \
    sudo yum -y --enablerepo=puppetlabs-products,puppetlabs-deps --quiet install puppet-server

    # Enale all repos
    sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/puppetlabs.repo

    # Configure /etc/hosts file
    echo "" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "# Host config for Puppet Master and Agent Nodes" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.32.5    puppet.mheducation.com  puppet"  | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.32.10   node01.mheducation.com  node01"  | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.32.20   node02.mheducation.com  node01"  | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.32.30   node03.mheducation.com  node02"  | sudo tee --append /etc/hosts 2> /dev/null

    # Add optional alternate DNS names to /etc/puppet/puppet.conf
    sudo sed -i 's/.*\[main\].*/&\ndns_alt_names = puppet,puppet.mheducation.com/' /etc/puppet/puppet.conf

    # Install some initial puppet modules on Puppet Master server
    sudo puppet module install puppetlabs-ntp
    sudo puppet module install garethr-docker
    sudo puppet module install puppetlabs-git
    sudo puppet module install puppetlabs-vcsrepo
    sudo puppet module install garystafford-fig

    # symlink manifest from Vagrant synced folder location
    ln -s /vagrant/puppet/site.pp /etc/puppet/manifests/site.pp
fi

# Start Puppet master
#puppet master --verbose --no-daemonize
#PID=$! ; sleep 10 ; kill -9 $PID
#systemctl start  puppetmaster
#systemctl enable puppetmaster
