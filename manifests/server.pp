#
# This class will add the official Graylog repository, install, and configure
# Graylog. It also manages java options, and the Graylog service.
#
# @param package_name
#   The name of the graylog package to install (default: graylog-server)
#
# @param package_version
#   The version of the package to install (default: installed)
#
# @param config
#   The hash containing the Graylog server configuration
#
# @param user
#   The user to own the Graylog configuration files. This setting must match the
#   user Graylog runs as (default: graylog)
#
# @param group
#   The group to own the Graylog configuration files. This setting must match
#   the user Graylog runs as (default: graylog)
#
# @param ensure
#   What state to ensure the service is in (default: running)
#
# @param enable
#   Whether or not to enable the service (default: true)
#
# @param java_initial_heap_size
#   The initial (minimum) heap size for java (-Xms) (default: 1g)
#
# @param java_max_heap_size
#   The maximum heap size for java (-Xmx) (default: 1g)
#
# @param java_opts
#   Any additional options to set for java
#
# @param restart_on_package_upgrade
#   Whether or not to restart the graylog service when the package is updated
#   (default: false)
#
class graylog::server (
  String $package_name = $graylog::params::package_name,
  String $package_version = $graylog::params::package_version,
  Optional[Hash] $config = undef,
  String $user = $graylog::params::server_user,
  String $group = $graylog::params::server_group,
  Variant[
    Enum[
      'stopped',
      'running',
      'true',
      'false',
    ],
    Boolean
  ] $ensure = running,
  Boolean $enable = true,
  String $java_initial_heap_size = $graylog::params::java_initial_heap_size,
  String $java_max_heap_size = $graylog::params::java_max_heap_size,
  String $java_opts = $graylog::params::java_opts,
  Boolean $restart_on_package_upgrade = false,
) inherits graylog::params {
  if $config == undef {
    fail('Missing "config" setting!')
  }

  # Check mandatory settings
  unless 'password_secret' in $config {
    fail('Missing "password_secret" config setting!')
  }
  if 'root_password_sha2' in $config {
    if length($config['root_password_sha2']) < 64 {
      fail('The root_password_sha2 parameter does not look like a SHA256 checksum!')
    }
  } else {
    fail('Missing "root_password_sha2" config setting!')
  }

  $data = stdlib::merge($graylog::params::default_config, $config)

  $notify = $restart_on_package_upgrade ? {
    true    => Service['graylog-server'],
    default => undef,
  }

  package { $package_name:
    ensure  => $package_version,
    notify  => $notify,
    require => Class['graylog::repository'],
  }

  file { '/etc/graylog/server/server.conf':
    ensure  => file,
    owner   => $user,
    group   => $group,
    mode    => '0640',
    content => Sensitive(template("${module_name}/server/graylog.conf.erb")),
    require => Package[$package_name],
  }

  case $facts['os']['family'] {
    'debian': {
      file { '/etc/default/graylog-server':
        ensure  => file,
        owner   => $user,
        group   => $group,
        mode    => '0640',
        content => epp("${module_name}/server/environment.epp",
          {
            'java_initial_heap_size' => $java_initial_heap_size,
            'java_max_heap_size'     => $java_max_heap_size,
            'java_opts'              => $java_opts
        }),
        require => Package[$package_name],
      }
    }
    'redhat': {
      file { '/etc/sysconfig/graylog-server':
        ensure  => file,
        owner   => $user,
        group   => $group,
        mode    => '0640',
        content => epp("${module_name}/server/environment.epp",
          {
            'java_initial_heap_size' => $java_initial_heap_size,
            'java_max_heap_size'     => $java_max_heap_size,
            'java_opts'              => $java_opts
        }),
        require => Package[$package_name],
      }
    }
    default: {
      fail("${facts['os']['family']} is not supported!")
    }
  }

  service { 'graylog-server':
    ensure     => $ensure,
    enable     => $enable,
    hasstatus  => true,
    hasrestart => true,
  }
}
