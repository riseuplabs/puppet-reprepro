class reprepro {

  $basedir = '/srv/reprepro'

  package {
    "reprepro":
      ensure => '3.9.2-1~bpo40+1';

    "inoticoming":
      ensure => '0.2.0-1~bpo40+1';
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

    "$basedir/README.txt":
    mode => 0664, owner => root, group => reprepro,
    source => "puppet://$servername/reprepro/README.txt";

    "$basedir/.gnupg":
    mode => 750, owner => reprepro, group => root,
    ensure => directory;
  }

  exec { "reprepro -b $basedir createsymlinks":
    refreshonly => true,
    subscribe => File["$basedir/conf/distributions"],
    path => "/usr/bin:/bin",
  }

  exec { "gpg --export -a `gpg --with-colon --list-secret-keys | awk -F ':' '{ print $5 }' | head -1` > $basedir/key.asc":
    creates => "$basedir/key.asc",
    subscribe => File["$basedir/.gnupg"],
  }

# TODO: additional things this class could do
# setup inotincoming cronjob
# ensure it stays running
# setup needeed lines in apache site config file

}
