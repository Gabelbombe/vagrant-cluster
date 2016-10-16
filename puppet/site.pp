node default {
  # Test message
  notify { "Debug output on ${hostname} node.": }

  include ntp, git, mosburn-editors, centos7utils, epel
}

node 'node01.mosburn.com', 'node02.mosburn.com', 'node03.mosburn.com' {
  # Test message
  notify { "Debug output on ${hostname} node.": }

  include ntp, git, mosburn-editors, centos7utils, epel
}
