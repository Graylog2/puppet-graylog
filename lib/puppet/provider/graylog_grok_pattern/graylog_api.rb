require_relative '../graylog_api'

Puppet::Type.type(:graylog_grok_pattern).provide(:graylog_api, parent: Puppet::Provider::GraylogAPI) do

  mk_resource_methods

  def self.instances
    results = get('system/grok')
    results['patterns'].map do |data|
      item = new(
        ensure: :present,
        name: data['name'],
        pattern: data['pattern'],
      )
      item.rest_id = data['id']
      item
    end
  end

  def flush
    simple_flush("system/grok",{
      name: resource[:name],
      pattern: resource[:pattern],
    })
  end

end