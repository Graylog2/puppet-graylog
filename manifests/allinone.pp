#
# This class is intended to be used to create a server with opensearch,
# mongodb, and graylog installed and configured.
#
# @param opensearch
#   A hash containing the opensearch configuration options.
#   An example would look (at a minimum) like
#   {
#     'version'  => '2.15.0',
#     'settings' => {
#       'setting_a' => 'value'
#     }
#   }
#
# @param graylog
#   A hash containing the graylog configuration options
#   An example would look like
#   {
#     'major_version' => '6.1',
#     'config'        => {
#       'password_secret'    => 'something',
#       'root_password_sha2' => 'abcd...'
#     }
#   }
#
class graylog::allinone (
  Hash $opensearch,
  Hash $graylog,
) inherits graylog::params {
  class { 'mongodb::globals':
    manage_package_repo => true,
    version             => '5.0.30',
  }
  -> class { 'mongodb::server':
    bind_ip => ['127.0.0.1'],
  }

  if 'version' in $opensearch {
    $opensearch_version = $opensearch['version']
  } else {
    $opensearch_version = '2.15.0'
  }

  class { 'opensearch':
    version  => $opensearch_version,
    settings => $opensearch['settings'],
  }

  if 'major_version' in $graylog {
    $graylog_major_version = $graylog['major_version']
  } else {
    $graylog_major_version = $graylog::params::major_version
  }

  class { 'graylog::repository':
    version => $graylog_major_version,
  }
  -> class { 'graylog::server':
    package_name           => $graylog['package_name'],
    config                 => $graylog['config'],
    java_initial_heap_size => $graylog['java_initial_heap_size'],
    java_max_heap_size     => $graylog['java_max_heap_size'],
    java_opts              => $graylog['java_opts'],
  }
}
