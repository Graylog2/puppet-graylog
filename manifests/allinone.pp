class graylog::allinone(
  Hash $elasticsearch,
  Hash $graylog,
) inherits graylog::params {

  class {'::mongodb::globals':
    manage_package_repo => true,
  }->
  class {'::mongodb::server':
    bind_ip => ['127.0.0.1'],
  }


  if has_key($elasticsearch, 'version') {
    $es_version = $elasticsearch['version']
  } else {
    $es_version = '5.6.5'
  }
  if has_key($elasticsearch, 'repo_version') {
    $es_repo_version = $elasticsearch['repo_version']
  } else {
    $es_repo_version = 5
  }

  class { 'elastic_stack::repo':
    version => $es_repo_version,
  }

  class { 'elasticsearch':
    version     => $es_version,
    manage_repo => true,
  }->
  elasticsearch::instance { 'graylog':
    config => {
      'cluster.name' => 'graylog',
      'network.host' => '127.0.0.1',
    },
  }

  class { 'graylog::repository':
    version => $graylog['major_version'],
  }->
  class { 'graylog::server':
    * => $graylog['settings'],
  }
}
