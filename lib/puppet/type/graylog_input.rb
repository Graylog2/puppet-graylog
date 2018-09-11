Puppet::Type.newtype(:graylog_input) do

  ensurable

  newparam(:name) do
    desc 'The name of the Input Source'
  end

  newproperty(:type) do
    desc 'The type of the input'
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
