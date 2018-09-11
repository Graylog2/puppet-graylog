require_relative '../graylog_api'

Puppet::Type.type(:graylog_input).provide(:graylog_api, parent: Puppet::Provider::GraylogAPI) do

  INPUT_TYPES = {
    gelf_tcp: 'org.graylog2.inputs.gelf.tcp.GELFTCPInput',
    gelf_udp: 'org.graylog2.inputs.gelf.udp.GELFUDPInput',
    gelf_http: 'org.graylog2.inputs.gelf.http.GELFHttpInput', 
    gelf_amqp: 'org.graylog2.inputs.gelf.amqp.GELFAMQPInput', 
    gelf_kafka: 'org.graylog2.inputs.gelf.kafka.GELFKafkaInput', 
    syslog_tcp: 'org.graylog2.inputs.syslog.tcp.SyslogTCPInput', 
    syslog_udp: 'org.graylog2.inputs.syslog.udp.SyslogUDPInput', 
    syslog_amqp: 'org.graylog2.inputs.syslog.amqp.SyslogAMQPInput', 
    syslog_kafka: 'org.graylog2.inputs.syslog.kafka.SyslogKafkaInput',
    raw_tcp: 'org.graylog2.inputs.raw.tcp.RawTCPInput', 
    raw_udp: 'org.graylog2.inputs.raw.udp.RawUDPInput', 
    raw_amqp: 'org.graylog2.inputs.raw.amqp.RawAMQPInput',
    raw_kafka: 'org.graylog2.inputs.raw.kafka.RawKafkaInput', 
    cef_tcp: 'org.graylog.plugins.cef.input.CEFTCPInput', 
    cef_udp: 'org.graylog.plugins.cef.input.CEFUDPInput', 
    cef_amqp: 'org.graylog.plugins.cef.input.CEFAmqpInput', 
    cef_kafka: 'org.graylog.plugins.cef.input.CEFKafkaInput',  
    aws_cloudtrail: 'org.graylog.aws.inputs.cloudtrail.CloudTrailInput', 
    aws_cloudwatch: 'org.graylog.aws.inputs.cloudwatch.CloudWatchLogsInput', 
    aws_flow_logs: 'org.graylog.aws.inputs.flowlogs.FlowLogsInput',
    netflow_udp: 'org.graylog.plugins.netflow.inputs.NetFlowUdpInput',
    beats: 'org.graylog.plugins.beats.BeatsInput', 
    json_path: 'org.graylog2.inputs.misc.jsonpath.JsonPathInput', 
    fake: 'org.graylog2.inputs.random.FakeHttpMessageInput',
  }

  mk_resource_methods

  def self.instances
    results = get('system/inputs')
    results['inputs'].map do |data|
      input = new(
        ensure: :present,
        name: data['title'],
        type: data['type'],
        scope: (data['global'] ? 'global' : 'local'),
        configuration: data['attributes'],
      )
      input.rest_id = data['id']
      input
    end
  end

  def flush
    binding.pry
    simple_flush("system/inputs",{
      title: resource[:name],
      type: resource[:type],
      global: global?,
      configuration: resource[:configuration],
      node: node,
    })
  end

  def global?
    resource[:scope] == :global
  end

  def node
    global? ? nil : node_id
  end

end