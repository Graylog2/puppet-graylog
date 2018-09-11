require 'puppet/property/boolean'

Puppet::Type.newtype(:graylog_stream) do

  ensurable

  newparam(:name) do
    desc 'The name of the stream'
  end

  newproperty(:description) do
    desc 'A description of the stream'
  end

  newproperty(:enabled, boolean: true, parent: Puppet::Property::Boolean) do
    desc "Whether this stream is enabled"
    defaultto(true)
  end


  newproperty(:matching_type) do
    desc "Whether messages must match all rules, or any rule, to belong to the stream"
    newvalues(:AND, :OR)
    aliasvalue(:and, :AND)
    aliasvalue(:or, :OR)
    aliasvalue(:all, :AND)
    aliasvalue(:any, :OR)
    defaultto(:AND)
  end

  newproperty(:rules, array_matching: :all) do
    desc "Permissions this role provides, see /system/permissions API endpoint for list of valid permissions"
    munge do |rule|
      { 'field' => :undef, 'description' => :undef, 'type' => :undef, 'inverted' => false, 'value' => :undef }.merge(rule)
    end
  end

  newproperty(:remove_matches_from_default_stream, boolean: true, parent: Puppet::Property::Boolean) do
    desc "Whether messages that appear in this stream get removed from the default stream"
    defaultto(false)
  end

  newproperty(:index_set) do
    desc "The name of the index set that stream operates on"
  end
  # TODO: Implement alert_conditions
  # TODO: Implement alert_receivers
  # TODO: Implement outputs


  autorequire('graylog_api') {'api'}
end
