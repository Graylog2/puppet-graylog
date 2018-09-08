require_relative '../graylog_api'
require 'pry'

Puppet::Type.type(:graylog_index_set).provide(:graylog_api, parent: Puppet::Provider::GraylogAPI) do

  mk_resource_methods

  def self.instances
    results = get('system/indices/index_sets')
    results['index_sets'].map do |data|
      index_set = new(
        ensure: :present,
        name: data['title'],
        description: data['description'],
        prefix: data['index_prefix'],
        shards: data['shards'],
        replicas: data['replicas'],
        rotation_strategy: resource_type::ROTATION_STRATEGIES.key(data['rotation_strategy_class']),
        rotation_strategy_details: data['rotation_strategy'].reject {|k,v| k == 'type' },
        retention_strategy: resource_type::RETENTION_STRATEGIES.key(data['retention_strategy_class']),
        retention_strategy_details: data['retention_strategy'].reject {|k,v| k == 'type' },
        index_analyzer: data['index_analyzer'],
        max_segments: data['index_optimization_max_num_segments'],
        disable_index_optimization: data['index_optimization_disabled'],
      )
      index_set.rest_id = data['id']
      index_set
    end
  end

  def flush
    rot_strat = Puppet::Type::Graylog_index_set::ROTATION_STRATEGIES[resource[:rotation_strategy]]
    ret_strat = Puppet::Type::Graylog_index_set::RETENTION_STRATEGIES[resource[:retention_strategy]]
    simple_flush('system/indices/index_sets',{
      title: resource[:name],
      description: resource[:description],
      index_prefix: resource[:prefix],
      shards: resource[:shards],
      replicas: resource[:replicas],
      rotation_strategy_class: rot_strat,
      rotation_strategy: resource[:rotation_strategy_details].merge({type: "#{rot_strat}Config"}),
      retention_strategy_class: ret_strat,
      retention_strategy: resource[:retention_strategy_details].merge({type: "#{ret_strat}Config"}),
      index_analyzer: resource[:index_analyzer],
      index_optimization_max_num_segments: resource[:max_segments],
      index_optimization_disabled: resource[:disable_index_optimization],
      writable: true,
    })
  end

end