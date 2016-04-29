class graylog::repository(
  $version = $graylog::params::major_version,
  $url     = $graylog::params::repository_url,
  $release = $graylog::params::repository_release,
) inherits graylog::params {
  anchor { 'graylog::repository::begin': }
  anchor { 'graylog::repository::end': }

  case $::osfamily {
    'debian': {
      class { 'graylog::repository::apt':
        url     => $url,
        release => $release,
        version => $version,
      }
    }
    'redhat': {
      class { 'graylog::repository::yum':
        url => $url,
      }
    }
    default: {
      fail("${::osfamily} is not supported!")
    }
  }
}
