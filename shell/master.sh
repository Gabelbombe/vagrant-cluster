#!/bin/sh

# Run on VM to bootstrap Puppet Master server
if ps aux | grep "puppet master" | grep -v grep 2> /dev/null
then
    echo "Puppet Master is already installed. Exiting..."
else
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
#    echo "192.168.32.6    haproxy.mheducation.com haproxy" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.32.10   node01.mheducation.com  node01"  | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.32.20   node02.mheducation.com  node02"  | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.32.30   node03.mheducation.com  node03"  | sudo tee --append /etc/hosts 2> /dev/null

    # Add optional alternate DNS names to /etc/puppet/puppet.conf
    sudo sed -i 's/.*\[main\].*/&\ndns_alt_names = puppet,puppet.mheducation.com/' /etc/puppet/puppet.conf

    # Install some initial puppet modules on Puppet Master server
    sudo puppet module install puppetlabs-ntp
    sudo puppet module install puppetlabs-git
    sudo puppet module install puppetlabs-vcsrepo
    sudo puppet module install KyleAnderson-consul
    sudo puppet module install puppetlabs-haproxy
    sudo puppet module install puppetlabs-apache

    # symlink manifest from Vagrant synced folder locationsudo rpm -Uvh http://rbel.frameos.org/rbel6
    ln -s /vagrant/puppet/site.pp /etc/puppet/manifests/site.pp
fi

# Add mhedu to autosigning
echo '*.mheducation.com' >> /etc/puppet/autosign.conf

systemctl start  puppetmaster
systemctl enable puppetmaster

# Start Puppet master
# sudo service puppetmaster status  # test that puppet master was installed
# sudo service puppetmaster stop
# sudo puppet master --verbose --no-daemonize &
# sleep 10
#
# # Ctrl+C to kill puppet master
# sudo service puppetmaster start
# sudo puppet cert list --all       # check for 'puppet' cert
