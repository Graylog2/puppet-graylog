class graylog::repository(
  String           $version,
  Optional[String] $url = undef,
  String           $release,
) {
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
      }
    }
    'redhat': {
      class { 'graylog::repository::yum':
        url => $graylog_repo_url,
      }
    }
    default: {
      fail("${::osfamily} is not supported!")
    }
  }
}
