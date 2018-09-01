require_relative '../graylog_api'

Puppet::Type.type(:graylog_ldap_settings).provide(:graylog_api, parent: Puppet::Provider::GraylogAPI) do

  mk_resource_methods

  def self.instances
    result = get('system/ldap/settings')
    [new(name: 'ldap', **symbolize(result))]
  end

  def flush
    Puppet.info("Flushing graylog_ldap_settings")
    data = @property_hash.reject {|k,v| k == :name }
    put('system/ldap/settings',data)
  end

end