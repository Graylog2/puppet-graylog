Puppet::Type.newtype(:graylog_grok_pattern) do

  ensurable

  newparam(:name) do
    desc 'The token that represents the pattern'
  end

  newproperty(:pattern) do
    desc 'The literal pattern string'
  end

  autorequire('graylog_api') {'api'}
end
