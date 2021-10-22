class graylog::allinone(
  $elasticsearch,
  $graylog,
) inherits graylog::params {

  class {'::mongodb::globals':
    manage_package_repo => true,
    version             => '4.4.9',
  }->
  class {'::mongodb::server':
    bind_ip => ['127.0.0.1'],
  }


  if has_key($elasticsearch, 'version') {
    $es_version = $elasticsearch['version']
  } else {
    $es_version = '7.10.2'
  }

  class { 'elastic_stack::repo':
    oss => true,
  }

  class { 'elasticsearch':
    version     => $es_version,
    manage_repo => true,
    oss         => true,
    config      => {
      'cluster.name'             => 'graylog',
      'network.host'             => '127.0.0.1',
      'action.auto_create_index' => false
    },
  }


  if has_key($graylog, 'major_version') {
    $graylog_major_version = $graylog['major_version']
  } else {
    $graylog_major_version = $graylog::params::major_version
  }

  class { 'graylog::repository':
    version => $graylog_major_version,
  }->
  class { 'graylog::server':
    config                  => $graylog['config'],
    java_initial_heap_size  => $graylog['java_initial_heap_size'],
    java_max_heap_size      => $graylog['java_max_heap_size'],
  }
}
