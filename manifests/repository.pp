define reprepro::repository (
  $uploaders,
  $user = 'reprepro',
  $group = 'reprepro',
  $basedir = '/srv/reprepro',
  $origin  = $::domain,
  $architectures  = [ 'amd64', 'i386', 'source' ],
  $basedir_mode  = '0771',
  $incoming_mode = '1777',
  $manage_distributions_conf    = true,
  $manage_incoming_conf         = true,
  $handle_incoming_with_cron    = false,
  $handle_incoming_with_inotify = false,
  $signwith = 'yes',
  $secring_source = undef,
  $index_template = 'reprepro/index.html.erb',
) {
  include reprepro

  if !defined(User[$user]) {
    user { $user:
      ensure   => 'present',
      home     => $basedir,
      gid      => $group,
      password => '*',
      comment  => 'reprepro sandbox',
      require  => Group[$group],
    }
  }

  if !defined(Group[$group]) {
    group { $group:
      ensure => present,
    }
  }

  File {
    owner => $user,
    group => $group,
  }

  file { $basedir:
    ensure => directory,
    mode   => $basedir_mode,
  }
  file { "${basedir}/conf":
    ensure => directory,
    mode   => '0770',
  }
  file { "${basedir}/db":
    ensure => directory,
    mode   => '0770',
  }
  file { "${basedir}/dists":
    ensure => directory,
    mode   => '0775',
  }
  file { "${basedir}/pool":
    ensure => directory,
    mode   => '0775',
  }
  file { "${basedir}/incoming":
    ensure => directory,
    mode   => $incoming_mode,
  }
  file { "${basedir}/logs":
    ensure => directory,
    mode   => '0775',
  }
  file { "${basedir}/tmp":
    ensure => directory,
    mode   => '0775',
  }
  file { "${basedir}/conf/uploaders":
    mode    => '0640',
    owner   => root,
    content => template('reprepro/uploaders.erb'),
  }
  file { "${basedir}/index.html":
    mode    => '0664',
    owner   => root,
    content => template($index_template),
  }

  file { "${basedir}/.gnupg":
    ensure => directory,
    mode   => '0700',
  }
  file { "${basedir}/.gnupg/secring.gpg":
    ensure => present,
    source => $secring_source,
    mode   => '0600',
  }

  exec { "/usr/local/bin/reprepro-export-key '${basedir}'":
    creates     => "${basedir}/key.asc",
    user        => $user,
    subscribe   => File["${basedir}/.gnupg/secring.gpg"],
    require     => File['/usr/local/bin/reprepro-export-key'],
  }


  file { "${basedir}/conf/distributions":
    ensure => present,
  }
  if $manage_distributions_conf {
    File["${basedir}/conf/distributions"] {
      owner   => root,
      mode    => '0664',
      content => template('reprepro/distributions.erb'),
    }

    exec { "reprepro -b ${basedir} createsymlinks":
        refreshonly => true,
        subscribe   => File["${basedir}/conf/distributions"],
        user        => $user,
        path        => '/usr/bin:/bin',
    }
    exec { "reprepro -b ${basedir} export":
        refreshonly => true,
        user        => $user,
        subscribe   => File["${basedir}/conf/distributions"],
        path        => '/usr/bin:/bin',
    }
  }

  file { "${basedir}/conf/incoming":
    ensure => present,
  }
  if $manage_incoming_conf {
    File["${basedir}/conf/incoming"] {
      mode   => '0664',
      owner  => root,
      source => 'puppet:///modules/reprepro/incoming'
    }
  }

  # Handling of incoming with cron

  $cron_presence = $handle_incoming_with_cron ? {
    true    => present,
    default => absent,
  }

  cron { "reprepro-${name}":
    ensure  => $cron_presence,
    command => "/usr/bin/reprepro --silent -b ${basedir} processincoming incoming",
    user    => $user,
    minute  => '*/5',
    require => [ Package['reprepro'], File["${basedir}/conf/distributions"],
                 File["${basedir}/incoming"], ],
  }

  # Handling of incoming with inoticoming

  $inoticoming_presence = $handle_incoming_with_inotify ? {
    true    => present,
    default => absent,
  }
  $inoticoming_enabled = $handle_incoming_with_inotify ? {
    true    => true,
    default => false,
  }

  if !defined(Package['inoticoming']) {
    package { 'inoticoming':
      ensure => $inoticoming_presence,
    }
  }

  file { '/etc/init.d/reprepro':
    ensure => $inoticoming_presence,
    owner  => root,
    group  => root,
    mode   => '0755',
    source => 'puppet:///modules/reprepro/inoticoming.init',
  }
  file { '/etc/default/reprepro':
    ensure  => $inoticoming_presence,
    owner   => root,
    group   => root,
    mode    => '0755',
    content => template('reprepro/inoticoming.default.erb'),
  }

  service { 'reprepro':
    ensure  => $inoticoming_enabled,
    enable  => $inoticoming_enabled,
    pattern => 'inoticoming.*reprepro.*processincoming',
    require => [ Package['reprepro'], Package['inoticoming'],
                 File['/etc/default/reprepro'],
                 File['/etc/init.d/reprepro'],
                 File["${basedir}/incoming"] ],
  }

# TODO: setup needeed lines in apache site config file

}
