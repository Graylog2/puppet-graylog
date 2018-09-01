require 'puppet/property/boolean'

Puppet::Type.newtype(:graylog_input) do

  ensurable

  newparam(:name) do
    desc 'The name of the Input Source'
  end

  newproperty(:type) do
    desc 'The type of the input'
    newvalues(
      :gelf_tcp, :gelf_udp, :gelf_http, :gelf_amqp, :gelf_kafka, 
      :syslog_tcp, :syslog_udp, :syslog_amqp, :syslog_kafka,
      :raw_tcp, :raw_udp, :raw_amqp, :raw_kafka,
      :cef_tcp, :cef_udp, :cef_amqp, :cef_kafka,       
      :aws_cloudtrail, :aws_cloudwatch, :aws_flow_logs,
      :netflow_udp,
      :beats, :json_path, :fake,
    )
  end

  newproperty(:scope) do
    desc "Whether this input is defined on all nodes or just this node"
    newvalues(:local, :global)
    defaultto(:global)
  end

  newproperty(:configuration) do
    desc "A hash of configuration values for the input; structure varies by input type"
    isrequired
  end


  autorequire('graylog_api') {'api'}
end
