class reprepro (
  $uploaders = 'undefined',
  $basedir = '/srv/reprepro',
  $origin  = $::domain,
  $basedir_mode  = '0771',
  $incoming_mode = '1777',
  $manage_distributions_conf    = true,
  $manage_incoming_conf         = true,
  $handle_incoming_with_cron    = false,
  $handle_incoming_with_inotify = false,
){
  package {
    "reprepro": ensure => 'installed';
  }

  if $uploaders == 'undefined' {
    fail("The uploaders parameter is required by the reprepro class.")
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

  File {
    owner => reprepro,
    group => reprepro,
  }

  file {
    "$basedir":
    ensure => directory,
    mode => $basedir_mode;

    "$basedir/conf":
    ensure => directory,
    mode => 0770;

    "$basedir/db":
    ensure => directory,
    mode => 0770;

    "$basedir/dists":
    ensure => directory,
    mode => 0775;

    "$basedir/pool":
    ensure => directory,
    mode => 0775;

    "$basedir/incoming":
    ensure => directory,
    mode => $incoming_mode;

    "$basedir/logs":
    ensure => directory,
    mode => 0775;

    "$basedir/tmp":
    ensure => directory,
    mode => 0775;

    "$basedir/conf/distributions":
    ensure => present;

    "$basedir/conf/uploaders":
    mode => 0660, owner => root,
    content => template("reprepro/uploaders.erb");

    "$basedir/conf/incoming":
    ensure => present;

    "$basedir/index.html":
    mode => 0664, owner => root,
    content => template("reprepro/index.html.erb");

    "$basedir/.gnupg":
    mode => 700,
    ensure => directory;

    "$basedir/.gnupg/secring.gpg":
    mode => 600,
    ensure => present;

    "/usr/local/bin/reprepro-export-key":
    ensure  => present,
    content => template('reprepro/reprepro-export-key.sh.erb'),
    owner   => root,
    group   => root,
    mode    => 755,
  }

  if $manage_distributions_conf {
    File["$basedir/conf/distributions"] {
      owner   => root,
      mode    => 0664,
      content => template("reprepro/distributions.erb"),
    }

    exec {
      "reprepro -b $basedir createsymlinks":
        refreshonly => true,
        subscribe => File["$basedir/conf/distributions"],
        user => reprepro,
        path => "/usr/bin:/bin";
      "reprepro -b $basedir export":
        refreshonly => true,
        user => reprepro,
        subscribe => File["$basedir/conf/distributions"],
        path => "/usr/bin:/bin";
    }
  }

  if $manage_incoming_conf {
    File["$basedir/conf/incoming"] {
      mode => 0664,
      owner => root,
      source => "puppet://$server/modules/reprepro/incoming"
    }
  }

  # Handling of incoming with cron

  $cron_presence = $handle_incoming_with_cron ? {
    true    => present,
    default => absent,
  }

  cron { 'reprepro':
    ensure  => $cron_presence,
    command => "/usr/bin/reprepro --silent -b $basedir processincoming incoming",
    user    => reprepro,
    minute  => '*/5',
    require => [ Package['reprepro'], File["$basedir/conf/distributions"] ],
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

  package { 'inoticoming':
    ensure => $inoticoming_presence,
  }
  file { '/etc/init.d/reprepro':
    ensure => $inoticoming_presence,
    owner  => root,
    group  => root,
    mode   => 0755,
    source => "puppet://${server}/modules/reprepro/inoticoming.init",
  }
  file { '/etc/default/reprepro':
    ensure  => $inoticoming_presence,
    owner   => root, group => root, mode => 0755,
    content => template('reprepro/inoticoming.default.erb'),
  }

  service { 'reprepro':
    ensure => $inoticoming_enabled,
    enable => $inoticoming_enabled,
    pattern => 'inoticoming.*reprepro.*processincoming',
    hasstatus => false,
    require => [ Package['inoticoming'],
                 File['/etc/default/reprepro'],
                 File['/etc/init.d/reprepro'] ],
  }

  exec {
    "/usr/local/bin/reprepro-export-key":
      creates     => "$basedir/key.asc",
      user        => reprepro,
      subscribe   => File["$basedir/.gnupg/secring.gpg"],
      require     => File["/usr/local/bin/reprepro-export-key"],
  }

# TODO: setup needeed lines in apache site config file

}
