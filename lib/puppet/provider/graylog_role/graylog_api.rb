require_relative '../graylog_api'

Puppet::Type.type(:graylog_role).provide(:graylog_api, parent: Puppet::Provider::GraylogAPI) do

  mk_resource_methods

  def self.instances
    results = get('roles')
    items = results['roles'].map do |data|
      next if ['Admin', 'Reader'].include?(data['name'])
      new(
        ensure: :present,
        name: data['name'],
        description: data['description'],
        permissions: data['permissions'],
      )
    end
    items.compact
  end

  def flush
    simple_flush("roles",{
      name: resource[:name],
      description: resource[:description],
      permissions: resource[:permissions],
      read_only: false,
    })
  end


end