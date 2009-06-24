class reprepro {

  package {
    "reprepro":
      ensure => '3.9.2-1~bpo40+1';

    "inoticoming":
      ensure => '0.2.0-1~bpo40+1';
  }

  group { "reprepro":
    ensure => "present",
  }


  file {
    "/srv/reprepro":
    ensure => directory,
    mode => 0771, owner => root, group => reprepro;

    "/srv/reprepro/conf":
    ensure => directory,
    mode => 0770, owner => root, group => reprepro;

    "/srv/reprepro/db":
    ensure => directory,
    mode => 0770, owner => root, group => reprepro;

    "/srv/reprepro/dists":
    ensure => directory,
    mode => 0775, owner => root, group => reprepro;

    "/srv/reprepro/pool":
    ensure => directory,
    mode => 0775, owner => root, group => reprepro;

    "/srv/reprepro/incoming":
    ensure => directory,
    mode => 0775, owner => root, group => reprepro;

    "/srv/reprepro/logs":
    ensure => directory,
    mode => 0775, owner => root, group => reprepro;

    "/srv/reprepro/tmp":
    ensure => directory,
    mode => 0775, owner => root, group => reprepro;

    "/srv/reprepro/conf/distributions":
    mode => 0664, owner => root, group => reprepro,
    source => "$fileserver/reprepro/distributions";

    "/srv/reprepro/conf/uploaders":
    mode => 0660, owner => root, group => reprepro,
    source => "$fileserver/reprepro/uploaders";

    "/srv/reprepro/conf/incoming":
    mode => 0664, owner => root, group => reprepro,
    source => "$fileserver/reprepro/incoming";

    "/srv/reprepro/index.html":
    mode => 0664, owner => root, group => reprepro,
    source => "$fileserver/reprepro/index.html";
  }

# TODO: additional things this class could do
# setup inotincoming cronjob
# ensure it stays running
# setup needeed lines in apache site config file

}
