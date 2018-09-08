require 'puppet/property/boolean'
require 'pry'

Puppet::Type.newtype(:graylog_pipeline_rule) do

  ensurable

  newparam(:name) do
    desc 'The name of the pipeline rule'
  end

  newproperty(:description) do
    desc 'A description of the pipeline rule'
  end

  newproperty(:source) do
    desc 'The source code for the pipeline rule'
  end

  validate do
    match_data = self[:source].match(/\A\s*rule\s+"(.+?)"/)
    fail("Rule source does not appear to begin with a rule-title declaration!") unless match_data
    inline_name = match_data.captures[0]
    fail("Name in rule source (#{inline_name}) doesn't match resource title (#{self[:name]})!") unless inline_name == self[:name]
  end

  autorequire('graylog_api') {'api'}
end
