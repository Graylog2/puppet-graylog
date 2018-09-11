define graylog::input::syslog_udp(
  Boolean                $allow_override_date       = true,
  String                 $bind_address              = '0.0.0.0',
  Boolean                $expand_structured_data    = true,
  Boolean                $force_rdns                = false,
  Optional[String]       $override_source           = undef,
  Stdlib::Port           $port                      = 514,
  Integer                $recv_buffer_size          = '256 kB'.to_bytes,
  Enum['global','local'] $scope                     = 'global',
  Boolean                $store_full_message        = true,
){
  graylog_input { $name:
    type          => 'org.graylog2.inputs.syslog.udp.SyslogUDPInput',
    scope         => $scope,
    configuration => {
      allow_override_date       => $allow_override_date,
      bind_address              => $bind_address,
      expand_structured_data    => $expand_structured_data,
      force_rdns                => $force_rdns,
      recv_buffer_size          => $recv_buffer_size,
      override_source           => $override_source,
      port                      => $port,
      store_full_message        => $store_full_message,
    },
  }
}
