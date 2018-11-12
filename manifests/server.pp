class graylog::server(
  Hash    $config,
  String  $password_secret,
  String  $root_password,
  Boolean $enable          = true,
  String  $ensure          = running,
  String  $group           = $graylog::params::server_group,
  String  $package_version = $graylog::params::package_version,
  String  $user            = $graylog::params::server_user,
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
    subscribe  => [
      File['/etc/graylog/server/server.conf'],
      Package['graylog-server'],
    ],
  }

  $pattern = /http:\/\/[\w.-]+:(\d+)/ # lint:ignore:unquoted_resource_title This isn't even a resource declaration, get it together lint.

  if 'rest_listen_uri' in $config {
    $api_port = match($config['rest_listen_uri'],$pattern)[1]
  } else {
    $api_port = 9000
  }

  graylog_api { 'api':
    password => $root_password,
    port     => $api_port,
    require  => Service['graylog-server'],
  }
}
