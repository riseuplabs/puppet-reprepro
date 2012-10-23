class { 'reprepro':
  uploaders => ['DEADBEEF'],
  handle_incoming_with_cron => true,
  handle_incoming_with_inotify => true,
}
