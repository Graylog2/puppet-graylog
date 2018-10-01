define graylog::plugin(
  String $source_url,
){
  file { "/usr/share/graylog-server/plugin/${title}.jar":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => $source_url,
    require => Package['graylog-server'],
    notify  => Service['graylog-server'],
  }
}