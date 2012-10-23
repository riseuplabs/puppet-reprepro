class reprepro::cron inherits reprepro {
  cron { reprepro:
    command => "/usr/bin/reprepro --silent -b $basedir processincoming incoming",
    user => reprepro,
    minute => '*/5',
    require => [ Package['reprepro'], File["$basedir/conf/distributions"] ]
  }
}
