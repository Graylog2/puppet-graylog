define graylog::input::gelf_udp(
  String                 $bind_address              = '0.0.0.0',
  Integer                $decompress_size_limit     = '8 MB'.to_bytes,
  Optional[String]       $override_source           = undef,
  Stdlib::Port           $port                      = 12201,
  Integer                $recv_buffer_size          = '256 kB'.to_bytes,
  Enum['global','local'] $scope                     = 'global',
){

  graylog_input { $name:
    type          => 'org.graylog2.inputs.gelf.udp.GELFUDPInput',
    scope         => $scope,
    configuration => {
      bind_address              => $bind_address,
      decompress_size_limit     => $decompress_size_limit,
      recv_buffer_size          => $recv_buffer_size,
      override_source           => $override_source,
      port                      => $port,
    },
  }
}