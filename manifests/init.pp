class reprepro {
  package {
    "reprepro": ensure => 'installed';
  }

  user { "reprepro":
    ensure => "present",
    home => "$basedir",
    gid => "reprepro",
    password => "*",
    comment => "reprepro sandbox",
    require => Group["reprepro"],
  }

  if !defined(Group["reprepro"]) {
    group { "reprepro":
      ensure => present,
    }
  }

  file { '/usr/local/bin/reprepro-export-key':
    ensure  => present,
    source => "puppet:///modules/reprepro/reprepro-export-key.sh",
    owner   => root,
    group   => root,
    mode    => '0755',
  }
}
