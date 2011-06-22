class reprepro {

  case $reprepro_uploaders {
    '': { fail("You need the repository uploaders! Please set \$reprepro_uploaders in your config") }
  }

  $basedir = $reprepro_basedir ? {
    ''      => '/srv/reprepro',
    default => $reprepro_basedir,
  }

  case $lsbdistcodename {
    etch: { 
      package {
        "reprepro": ensure => '3.9.2-1~bpo40+1';
        "inoticoming": ensure => '0.2.0-1~bpo40+1';
      }
    }
    default: {
      package {
        "reprepro": ensure => 'installed';
        "inoticoming": ensure => 'installed';
      }
    }
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

  file {
    "$basedir":
    ensure => directory,
    mode => 0771, owner => reprepro, group => reprepro;

    "$basedir/conf":
    ensure => directory,
    mode => 0770, owner => root, group => reprepro;

    "$basedir/db":
    ensure => directory,
    mode => 0770, owner => reprepro, group => reprepro;

    "$basedir/dists":
    ensure => directory,
    mode => 0775, owner => reprepro, group => reprepro;

    "$basedir/pool":
    ensure => directory,
    mode => 0775, owner => reprepro, group => reprepro;

    "$basedir/incoming":
    ensure => directory,
    mode => 1777, owner => reprepro, group => reprepro;

    "$basedir/logs":
    ensure => directory,
    mode => 0775, owner => reprepro, group => reprepro;

    "$basedir/tmp":
    ensure => directory,
    mode => 0775, owner => reprepro, group => reprepro;

    "$basedir/conf/distributions":
    mode => 0664, owner => root, group => reprepro,
    content => template("reprepro/distributions.erb");

    "$basedir/conf/uploaders":
    mode => 0660, owner => root, group => reprepro,
    content => template("reprepro/uploaders.erb");

    "$basedir/conf/incoming":
    mode => 0664, owner => root, group => reprepro,
    source => "puppet://$server/modules/reprepro/incoming";

    "$basedir/index.html":
    mode => 0664, owner => root, group => reprepro,
    content => template("reprepro/index.html.erb");

    "$basedir/.gnupg":
    mode => 700, owner => reprepro, group => reprepro,
    ensure => directory;

    "$basedir/.gnupg/secring.gpg":
    mode => 600, owner => reprepro, group => reprepro,
    ensure => present;

    "/usr/local/bin/reprepro-export-key":
    ensure  => present,
    content => template('reprepro/reprepro-export-key.sh.erb'),
    owner   => root,
    group   => root,
    mode    => 755,
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
    "/usr/local/bin/reprepro-export-key":
      creates     => "$basedir/key.asc",
      user        => reprepro,
      subscribe   => File["$basedir/.gnupg/secring.gpg"],
      require     => File["/usr/local/bin/reprepro-export-key"],
      refreshonly => true,
  }

  cron { reprepro:
    command => "/usr/bin/reprepro --silent -b $basedir processincoming incoming",
    user => reprepro,
    minute => '*/5',
    require => [ Package['reprepro'], File["$basedir/conf/distributions"] ]
  }

# TODO: additional things this class could do
# ensure it stays running
# setup needeed lines in apache site config file

}
