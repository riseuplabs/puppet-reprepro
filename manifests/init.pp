class reprepro {

  $basedir = '/srv/reprepro'

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

  group { "reprepro":
    ensure => "present",
  }


  file {
    "$basedir":
    ensure => directory,
    mode => 0771, owner => root, group => reprepro;

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
    mode => 0775, owner => reprepro, group => reprepro;

    "$basedir/logs":
    ensure => directory,
    mode => 0775, owner => reprepro, group => reprepro;

    "$basedir/tmp":
    ensure => directory,
    mode => 0775, owner => reprepro, group => reprepro;

    "$basedir/conf/distributions":
    mode => 0664, owner => root, group => reprepro,
    source => "puppet://$servername/reprepro/distributions";

    "$basedir/conf/uploaders":
    mode => 0660, owner => root, group => reprepro,
    source => "puppet://$servername/reprepro/uploaders";

    "$basedir/conf/incoming":
    mode => 0664, owner => root, group => reprepro,
    source => "puppet://$servername/reprepro/incoming";

    "$basedir/index.html":
    mode => 0664, owner => root, group => reprepro,
    source => "puppet://$servername/reprepro/index.html";

    "$basedir/.gnupg":
    mode => 750, owner => reprepro, group => root,
    ensure => directory;
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
    "gpg --export -a `gpg --with-colon --list-secret-keys | awk -F ':' '{ print \$5 }' | head -1` > $basedir/key.asc":
      creates => "$basedir/key.asc",
      user => reprepro,
      subscribe => File["$basedir/.gnupg"],
      path => "/usr/bin:/bin";
  }

  cron { reprepro:
    command => "/usr/bin/reprepro --silent -b $basedir processincoming incoming",
    user => reprepro,
    hour => '*',
    minute => '*/5',
    require => [ Package['reprepro'], File["$basedir/conf/distributions"] ]
  }

# TODO: additional things this class could do
# ensure it stays running
# setup needeed lines in apache site config file

}
