class graylog::repository(
  $version = $graylog::params::major_version,
  $url     = undef,
  $release = $graylog::params::repository_release,
) inherits graylog::params {
  anchor { 'graylog::repository::begin': }
  anchor { 'graylog::repository::end': }

  if $url == undef {
     $repo_url = $::osfamily ? {
       'debian' => 'https://downloads.graylog.org/repo/debian/',
       'redhat' => "https://downloads.graylog.org/repo/el/${repository_release}/${version}/\$basearch/",
       default  => fail("${::osfamily} is not supported!"),
     }
  } else {
    $repo_url = $url
  }

  case $::osfamily {
    'debian': {
      class { 'graylog::repository::apt':
        url     => $repo_url,
        release => $release,
        version => $version,
      }
    }
    'redhat': {
      class { 'graylog::repository::yum':
        url => $repo_url,
      }
    }
    default: {
      fail("${::osfamily} is not supported!")
    }
  }
}
