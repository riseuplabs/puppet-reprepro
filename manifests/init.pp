class reprepro {
  package {
    "reprepro": ensure => 'installed';
  }

  file { '/usr/local/bin/reprepro-export-key':
    ensure  => present,
    source => "puppet:///modules/reprepro/reprepro-export-key.sh",
    owner   => root,
    group   => root,
    mode    => '0755',
  }
}
