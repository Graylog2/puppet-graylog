define graylog::plugin(
  String $source_url,
){
  archive { "/usr/share/graylog-server/plugin/${title}.jar":
    user    => 'root',
    group   => 'root',
    source  => $source_url,
    extract => false,
    require => Package['graylog-server'],
    notify  => Service['graylog-server'],
  }
}