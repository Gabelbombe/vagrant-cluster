#!/bin/sh

# Run on VM to bootstrap Puppet Agent nodes
# http://blog.kloudless.com/2013/07/01/automating-development-environments-with-vagrant-and-puppet/

if ps aux | grep "puppet agent" | grep -v grep 2> /dev/null
then
    echo "Puppet Agent is already installed. Moving on..."
else
    sudo yum -y install https://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
    sudo yum -y --enablerepo=puppetlabs-products,puppetlabs-deps --quiet install puppet
fi

if cat /etc/crontab | grep puppet 2> /dev/null
then
    echo "Puppet Agent is already configured. Exiting..."
else
    sudo yum update -y -q && sudo yum upgrade -y -q

    sudo puppet resource cron puppet-agent ensure=present user=root minute=30 \
        command='/usr/bin/puppet agent --onetime --no-daemonize --splay'

    sudo puppet resource service puppet ensure=running enable=true

    # Configure /etc/hosts file
    echo "" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "# Host config for Puppet Master and Agent Nodes" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.32.5    puppet.mheducation.com  puppet" | sudo tee --append /etc/hosts 2> /dev/null &&  \
    echo "192.168.32.10   node01.mheducation.com  node01" | sudo tee --append /etc/hosts 2> /dev/null &&  \
    echo "192.168.32.20   node02.mheducation.com  node02" | sudo tee --append /etc/hosts 2> /dev/null &&  \
    echo "192.168.32.30   node03.mheducation.com  node03" | sudo tee --append /etc/hosts 2> /dev/null

    # Add agent section to /etc/puppet/puppet.conf
    echo "" && echo -e "[agent]\nserver=puppet" | sudo tee --append /etc/puppet/puppet.conf 2> /dev/null

    sudo puppet agent --enable
fi

# Add to master, should autosign
sudo service puppet status                # test that agent was installed
sudo puppet agent --test --waitforcert=60 # initiate certificate signing request (CSR)
