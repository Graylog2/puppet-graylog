class graylog::repository (
  $version     = $graylog::params::major_version,
  $manage_repo = true,
  $url         = undef,
  $proxy       = undef,
  $release     = $graylog::params::repository_release,
) inherits graylog::params {

  anchor { 'graylog::repository::begin': }

  if $url == undef {
    $graylog_repo_url = $::osfamily ? {
      'debian' => 'https://downloads.graylog.org/repo/debian/',
      'redhat' => "https://downloads.graylog.org/repo/el/${release}/${version}/\$basearch/",
      default  => fail("${::osfamily} is not supported!"),
    }
  } else {
    $graylog_repo_url = $url
  }

  case $::osfamily {
    'debian': {
      class { 'graylog::repository::apt':
        url     => $graylog_repo_url,
        release => $release,
        version => $version,
        proxy   => $proxy,
      }
    }
    'redhat': {
      if $manage_repo != false {
        class { 'graylog::repository::yum':
          url   => $graylog_repo_url,
          proxy => $proxy,
        }
      }
    }
    default: {
      fail("${::osfamily} is not supported!")
    }
  }
  anchor { 'graylog::repository::end': }
}
