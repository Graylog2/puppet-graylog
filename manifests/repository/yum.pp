#
# This class will add the official Graylog package repository and the pgp key
#
# @param url
#   The URL for the repository
#
# @param proxy
#   Proxy settings string
#
class graylog::repository::yum (
  String $url,
  Optional[String] $proxy,
) {
  $gpg_file = '/etc/pki/rpm-gpg/RPM-GPG-KEY-graylog'

  file { $gpg_file:
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0444',
    source => 'puppet:///modules/graylog/RPM-GPG-KEY-graylog',
  }
  yumrepo { 'graylog':
    descr    => 'The official Graylog package repository',
    baseurl  => $url,
    gpgkey   => "file://${gpg_file}",
    gpgcheck => true,
    enabled  => true,
    require  => File[$gpg_file],
    proxy    => $proxy,
  }
}
