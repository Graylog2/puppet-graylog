class graylog::server(
  Hash    $config,
  Boolean $enable = true,
  String  $ensure = running,
  String  $group,
  String  $package_version,
  String  $password_secret,
  String  $root_password,
  String  $user,
) {
  $root_password_sha2 = graylog::sha256($root_password)

  $default_config = {
    plugin_dir          => '/usr/share/graylog-server/plugin',
    message_journal_dir => '/var/lib/graylog-server/journal',
    content_packs_dir   => '/usr/share/graylog-server/contentpacks',
    is_master           => true,
    root_password_sha2  => $root_password_sha2,
    password_secret     => $password_secret,
  }

  $data = merge($default_config, $config)

  package { 'graylog-server':
    ensure => $package_version,
  }

  file { '/etc/graylog/server/server.conf':
    ensure    => file,
    owner     => $user,
    group     => $group,
    mode      => '0640',
    content   => template("${module_name}/server/graylog.conf.erb"),
    show_diff => true,
    require   => Package['graylog-server'],
  }

  service { 'graylog-server':
    ensure     => $ensure,
    enable     => $enable,
    hasstatus  => true,
    hasrestart => true,
    subscribe  => File['/etc/graylog/server/server.conf'],
  }

  $pattern = /http:\/\/[\w.-]+:(\d+)/

  if 'rest_listen_uri' in $config {
    $api_port = match($config['rest_listen_uri'],$pattern)[1]
  } else {
    $api_port = 9000
  }

  exec {"wait for graylog api":
    require => Service["graylog-server"],
    command => "/usr/bin/wget --spider --tries 10 --retry-connrefused --no-check-certificate ${config[rest_listen_uri]}",
  }

  graylog_api { 'api':
    password => $root_password,
    port     => $api_port,
    require  => Exec['wait for graylog api'],
  }
}


