#
# This class adds and manages the Graylog repository for Debian- and 
# RedHat-based Linux distributions
#
# @param version
#   The major version of the Graylog repository to add (e.g. 6.1)
#
# @param release
#   For Debian-based distributions, the release to use (e.g. stable)
#
# @param url
#   The URL to use for the repository, required if not debian or redhat-based
#   distribution
#
# @param proxy
#   Proxy settings for the specific package manager
#
class graylog::repository (
  String $version         = $graylog::params::major_version,
  String $release         = $graylog::params::repository_release,
  Optional[String] $url   = undef,
  Optional[String] $proxy = undef,
) inherits graylog::params {
  if $url == undef {
    $graylog_repo_url = $facts['os']['family'] ? {
      'debian' => 'https://downloads.graylog.org/repo/debian/',
      'redhat' => "https://downloads.graylog.org/repo/el/${release}/${version}/\$basearch/",
      default  => fail("${facts['os']['family']} is not supported!"),
    }
  } else {
    $graylog_repo_url = $url
  }

  case $facts['os']['family'] {
    'debian': {
      class { 'graylog::repository::apt':
        url     => $graylog_repo_url,
        release => $release,
        version => $version,
        proxy   => $proxy,
      }
    }
    'redhat': {
      class { 'graylog::repository::yum':
        url   => $graylog_repo_url,
        proxy => $proxy,
      }
    }
    default: {
      fail("${facts['os']['family']} is not supported!")
    }
  }
}
