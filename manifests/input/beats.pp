define graylog::input::beats(
  String                 $bind_address              = '0.0.0.0',
  Integer                $decompress_size_limit     = '8 MB'.to_bytes,
  Optional[String]       $override_source           = undef,
  Stdlib::Port           $port                      = 5044,
  Integer                $recv_buffer_size          = '1 MB'.to_bytes,
  Enum['global','local'] $scope                     = 'global',
  Boolean                $tcp_keepalive             = false,
  String                 $tls_cert_file             = '',
  String                 $tls_client_auth           = 'disabled',
  String                 $tls_client_auth_cert_file = '',
  Boolean                $tls_enable                = false,
  String                 $tls_key_file              = '',
  String                 $tls_key_password          = '',
){
  graylog_input { $name:
    type          => 'org.graylog.plugins.beats.BeatsInput',
    scope         => $scope,
    configuration => {
      bind_address              => $bind_address,
      recv_buffer_size          => $recv_buffer_size,
      override_source           => $override_source,
      port                      => $port,
      tcp_keepalive             => $tcp_keepalive,
      tls_cert_file             => $tls_cert_file,
      tls_client_auth           => $tls_client_auth,
      tls_client_auth_cert_file => $tls_client_auth_cert_file,
      tls_enable                => $tls_enable,
      tls_key_file              => $tls_key_file,
      tls_key_password          => $tls_key_password,
    },
  }
}
