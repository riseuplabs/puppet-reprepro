class reprepro::lighty inherits lighttpd {
  include reprepro
  file { '/etc/lighttpd/conf-available/20-reprepro.conf':
      ensure  => present,
      content => "alias.url += ( \"/debian/\" => \"${reprepro::basedir}/\" )\n";

    '/etc/lighttpd/conf-enabled/20-reprepro.conf':
      ensure  => link,
      target  => '/etc/lighttpd/conf-available/20-reprepro.conf',
      require => File['/etc/lighttpd/conf-available/20-reprepro.conf'],
      notify  => Service['lighttpd'];
  }
}
