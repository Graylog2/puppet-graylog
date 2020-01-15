class graylog::params {
  $major_version = '3.0'
  $package_version = 'installed'

  $repository_release = 'stable'

  $default_config = {
    'bin_dir'             => '/usr/share/graylog-server/bin',
    'data_dir'            => '/var/lib/graylog-server',
    'plugin_dir'          => '/usr/share/graylog-server/plugin',
    'message_journal_dir' => '/var/lib/graylog-server/journal',
    'is_master'           => true,
  }

  $server_user = 'graylog'
  $server_group = 'graylog'
  String $java_opts              = "-Xms1g -Xmx4g -XX:NewRatio=1 -server -XX:+ResizeTLAB -XX:+UseConcMarkSweepGC -XX:+CMSConcurrentMTEnabled -XX:+CMSClassUnloadingEnabled -XX:+UseParNewGC -XX:-OmitStackTraceInFastThrow"
  String $java_path              = "/usr/bin/java"
  String $graylog_server_args    = ""
  String $graylog_server_wrapper = ""

  if $facts['os']['family'] == 'Debian' {
    $graylog_jvm__settings  = "/etc/default/graylog-server"
  }
  else {
    $graylog_jvm__settings  = "/etc/sysconfig/graylog-server"
  }

}
