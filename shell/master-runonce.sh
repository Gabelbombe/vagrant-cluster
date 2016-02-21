#!/bin/bash

# Start Puppet master
sudo service puppetmaster status  # test that puppet master was installed
sudo service puppetmaster stop

# Ctrl+C to kill puppet master
sudo puppet master --verbose --no-daemonize &
PID=$! ; sleep 10 ; sudo kill $PID

sudo service puppetmaster start
sudo puppet cert list --all       # check for `puppet` cert

ABSOLUTE_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)/`basename "${BASH_SOURCE[0]}"`
rm -f $ABSOLUTE_PATH
