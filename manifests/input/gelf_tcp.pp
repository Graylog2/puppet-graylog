define graylog::input::gelf_tcp(
  String                 $bind_address              = '0.0.0.0',
  Integer                $decompress_size_limit     = '8 MB'.to_bytes,
  Integer                $max_message_size          = '2 MB'.to_bytes,
  Optional[String]       $override_source           = undef,
  Stdlib::Port           $port                      = 12201,
  Integer                $recv_buffer_size          = '1 MB'.to_bytes,
  Enum['global','local'] $scope                     = 'global',
  Boolean                $tcp_keepalive             = false,
  String                 $tls_cert_file             = '',
  String                 $tls_client_auth           = 'disabled',
  String                 $tls_client_auth_cert_file = '',
  Boolean                $tls_enable                = false,
  String                 $tls_key_file              = '',
  String                 $tls_key_password          = '',
  Boolean                $use_null_delimiter        = true,
){
  graylog_input { $name:
    type         => 'org.graylog2.inputs.gelf.tcp.GELFTCPInput',
    scope         => $scope,
    configuration => {
      bind_address              => $bind_address,
      decompress_size_limit     => $decompress_size_limit,
      max_message_size          => $max_message_size,
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
      use_null_delimiter        => $use_null_delimiter,
    },
  }
}