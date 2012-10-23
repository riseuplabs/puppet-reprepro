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

  exec { "reprepro_init_script":
      command => "/usr/sbin/update-rc.d reprepro defaults",
      unless => "/bin/ls /etc/rc3.d/ | /bin/grep reprepro",
      require => File["/etc/init.d/reprepro"],
  }
  service { "reprepro":
      ensure => "running",
      pattern => "inoticoming.*reprepro.*processincoming",
      hasstatus => false,
      require => [File["/etc/default/reprepro"],
                  Exec["reprepro_init_script"],
                  File["/etc/init.d/reprepro"] ],
  }
}
