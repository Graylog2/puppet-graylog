class graylog::params {
  $major_version = '2.1'
  $package_version = 'installed'

  $repository_release = 'stable'

  $repository_url = $::osfamily ? {
    'debian' => 'https://packages.graylog2.org/debian/',
    'redhat' => "https://packages.graylog2.org/el/${repository_release}/${major_version}/\$basearch/",
    default  => fail("${::osfamily} is not supported!"),
  }

  $default_config = {
    'plugin_dir'          => '/usr/share/graylog-server/plugin',
    'message_journal_dir' => '/var/lib/graylog-server/journal',
    'content_packs_dir'   => '/usr/share/graylog-server/contentpacks',
    'is_master'           => true,
  }

  $server_user = 'graylog'
  $server_group = 'graylog'
}
