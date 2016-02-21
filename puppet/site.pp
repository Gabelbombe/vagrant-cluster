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

node 'haproxy.mheducation.com' {
  # Test message
  notify { "Debug output on proxy ${hostname} node.": }

  include ntp, git, haproxy

  class haproxy_node_config () inherits haproxy {
    haproxy::listen { 'puppet00':
      collect_exported => false,
      ipaddress        => '*',
      ports            => '80',
      mode             => 'http',
      options          => {
        'option'  => ['httplog'],
        'balance' => 'roundrobin',
      },
    }

    Haproxy::Balancermember <<| listening_service == 'puppet00' |>>

    haproxy::balancermember { 'haproxy':
      listening_service => 'puppet00',
      server_names      => ['node01.mheducation.com', 'node02.mheducation.com', 'node03.mheducation.com'],
      ipaddresses       => ['192.168.32.10',          '192.168.32.20',          '192.168.32.30'],
      ports             => '80',
      options           => 'check',
    }
  }
}
