require 'puppet/property/boolean'

Puppet::Type.newtype(:graylog_pipeline) do

  ensurable

  newparam(:name) do
    desc 'The name of the pipeline'
  end

  newproperty(:description) do
    desc 'A description of the pipeline'
  end

  newproperty(:source) do
    desc 'The source code for the pipeline'
  end

  newproperty(:connected_streams, array_matching: :all) do
    desc "Streams to process with this pipeline"
  end

  validate do
    match_data = self[:source].match(/\A\s*pipeline\s+"(.+?)"/)
    fail("Pipeline source does not appear to begin with a pipeline-title declaration!") unless match_data
    inline_name = match_data.captures[0]
    fail("Name in pipeline source (#{inline_name}) doesn't match resource title (#{self[:name]})!") unless inline_name == self[:name]
  end

  autorequire('graylog_api') { 'api' }
  autorequire('graylog_stream') { self[:connected_streams] }
end
