class reprepro::inotify inherits reprepro {
  case $lsbdistcodename {
    etch: {
      package {
        "inoticoming": ensure => '0.2.0-1~bpo40+1';
      }
    }
    default: {
      package {
        "inoticoming": ensure => 'installed';
      }
    }
  }
  file { "/etc/init.d/reprepro":
      owner => root, group => root, mode => 0755,
      source => "puppet://$server/modules/reprepro/inoticoming.init";
  }
  file { "/etc/default/reprepro":
      ensure => present,
      owner => root, group => root, mode => 0755,
      content => template('reprepro/inoticoming.default.erb'),
  }

  service { "reprepro":
      ensure => "running",
      pattern => "inoticoming.*reprepro.*processincoming",
      hasstatus => false,
      require => [File["/etc/default/reprepro"],
                  File["/etc/init.d/reprepro"] ],
  }
}
