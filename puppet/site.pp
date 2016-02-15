node default {
  # Test message
  notify { "Debug output on ${hostname} node.": }

  include ntp, git
}

node 'node01.mheducation.com', 'node02.mheducation.com', 'node03.mheducation.com' {
  # Test message
  notify { "Debug output on ${hostname} node.": }

  include ntp, git
}
