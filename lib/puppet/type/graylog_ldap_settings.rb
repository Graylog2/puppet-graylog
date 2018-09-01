require 'puppet/property/boolean'

Puppet::Type.newtype(:graylog_ldap_settings) do

  newparam(:name) do
    desc 'must be "ldap", only one instance of graylog_ldap_settings is allowed'
    newvalues('ldap')
  end

  newproperty(:enabled, boolean: true, parent: Puppet::Property::Boolean) do
    desc "Whether to enable LDAP authentication"
  end

  newproperty(:system_username) do
    desc "Username to bind to LDAP server as"
  end

  newproperty(:system_password) do
    desc "Password to bind to LDAP server with"
  end

  newproperty(:ldap_uri) do
    desc "URI of LDAP server"
  end

  newproperty(:use_start_tls) do
    desc "Use StartTLS"
  end

  newproperty(:trust_all_certificates, boolean: true, parent: Puppet::Property::Boolean) do
    desc "Automatically trust all certificates"
  end

  newproperty(:active_directory, boolean: true, parent: Puppet::Property::Boolean) do
    desc "Is this an active directory server?"
  end

  newproperty(:search_base) do
    desc "The search base for user lookups"
  end

  newproperty(:search_pattern) do
    desc "The LDAP filter for user lookups"
  end

  newproperty(:default_group) do
    desc "The default group users are mapped to"
  end

  newproperty(:group_mapping) do
    desc "A hash mapping LDAP groups to Graylog groups"
  end

  newproperty(:group_search_base) do
    desc "The search base for group lookups"
  end

  newproperty(:group_id_attribute) do
    desc "The attribute by which LDAP groups are identified"
  end

  newproperty(:additional_default_groups, array_matching: :all) do
    desc "Other groups to apply by default"
  end

  newproperty(:group_search_pattern) do
    desc "The LDAP filter for group lookups"
  end

  newproperty(:display_name_attribute) do
    desc "The attribute for user display names"
  end

  autorequire('graylog_api') {'api'}
end
