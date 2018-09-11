require 'puppet/property/boolean'

Puppet::Type.newtype(:graylog_index_set) do

  ensurable

  newparam(:name) do
    desc 'The name of the Index Set'
  end

  newproperty(:description) do
    desc "A description of the Index Set"
  end

  newproperty(:prefix) do
    desc "A unique prefix used in Elasticsearch indices belonging to this index set. The prefix must start with a letter or number, and can only contain letters, numbers, '_', '-' and '+'."
    validate do |value|
      fail "The prefix must start with a letter or number, and can only contain letters, numbers, '_', '-' and '+'." unless value =~ /^[a-zA-Z0-9][a-zA-Z0-9+_-]*$/
    end
  end

  newproperty(:shards) do
    desc "Number of Elasticsearch shards used per index in this index set."
  end

  newproperty(:replicas) do
    desc "Number of Elasticsearch replicas used per index in this index set."
  end

  Puppet::Type::Graylog_index_set::ROTATION_STRATEGIES = {
    age: "org.graylog2.indexer.rotation.strategies.TimeBasedRotationStrategy",
    count: "org.graylog2.indexer.rotation.strategies.MessageCountRotationStrategy",
    size: "org.graylog2.indexer.rotation.strategies.SizeBasedRotationStrategy",
  }

  newproperty(:rotation_strategy) do
    desc "What type of rotation strategy to use"
    newvalues(*Puppet::Type::Graylog_index_set::ROTATION_STRATEGIES.keys)
  end

  newproperty(:rotation_strategy_details) do
    desc "Configuration details for the chosen rotation strategy"
  end

  Puppet::Type::Graylog_index_set::RETENTION_STRATEGIES = {
    close: "org.graylog2.indexer.retention.strategies.ClosingRetentionStrategy",
    delete: "org.graylog2.indexer.retention.strategies.DeletionRetentionStrategy",
    noop: "org.graylog2.indexer.retention.strategies.NoopRetentionStrategy",
  }

  newproperty(:retention_strategy) do
    desc "What type of retention strategy to use"
    newvalues(*Puppet::Type::Graylog_index_set::RETENTION_STRATEGIES.keys)
  end

  newproperty(:retention_strategy_details) do
    desc "Configuration details for the chosen rention strategy"
  end

  newproperty(:index_analyzer) do
    desc "Elasticsearch analyzer for this index set."
    defaultto('standard')
  end

  newproperty(:max_segments) do
    desc "Maximum number of segments per Elasticsearch index after optimization (force merge)."
    defaultto(1)
  end

  newproperty(:disable_index_optimization, boolean: true, parent: Puppet::Property::Boolean) do
    desc "Disable Elasticsearch index optimization (force merge) after rotation."
    defaultto(false)
  end

  autorequire('graylog_api') {'api'}
end
