Puppet::Type.newtype(:graylog_role) do

  ensurable

  newparam(:name) do
    desc 'The name of the role'
    validate do |value|
      fail "The Admin role is built-in and may not be changed" if value == 'Admin'
      fail "The Reader role is built-in and may not be changed" if value == 'Reader'
    end
  end

  newproperty(:description) do
    desc 'A description of the role'
  end

  newproperty(:permissions, array_matching: :all) do
    desc "Permissions this role provides, see /system/permissions API endpoint for list of valid permissions"
  end

  autorequire('graylog_api') {'api'}
end
