require_relative '../graylog_api'
require 'pry'

Puppet::Type.type(:graylog_stream).provide(:graylog_api, parent: Puppet::Provider::GraylogAPI) do

  mk_resource_methods

  def self.instances
    results = get('streams')
    results['streams'].map do |data|
      stream = new(
        ensure: :present,
        name: data['title'],
        description: data['description'],
        matching_type: data['matching_type'],
        enabled: !data['disabled'],
        rules: data['rules'].map {|defn| rule_from_data(defn) },
        remove_matches_from_default_stream: data['remove_matches_from_default_stream'],
        index_set: index_set_name_from_id(data['index_set_id']),
      )
      stream.rest_id = data['id']
      stream
    end
  end

  def self.index_set_name_from_id(index_set_id)
    get("system/indices/index_sets/#{index_set_id}")['title']
  end

  RULE_TYPES = %w{equals matches greater_than less_than field_presence contain always_match}

  def self.rule_from_data(data)
    {
      'field'       => data['field'],
      'description' => data['description'],
      'type'        => RULE_TYPES[data['type'] - 1],
      'inverted'    => data['inverted'],
      'value'       => data['value'],
    }
  end

  def flush
    simple_flush('streams',{
      title: resource[:name],
      description: resource[:description],
      matching_type: resource[:matching_type],
      rules: resource[:rules].map {|defn| data_from_rule(defn) },
      remove_matches_from_default_stream: resource[:remove_matches_from_default_stream],
      index_set_id: index_set_id_from_name(resource[:index_set])
    })
    if exists?
      if resource[:enabled]
        post("streams/#{rest_id}/resume")
      else
        post("streams/#{rest_id}/pause")
      end
    end
  end

  def set_rest_id_on_create(response)
    @rest_id = response['stream_id']
  end

  def data_from_rule(rule)
    {
      'field'       => rule['field'],
      'description' => rule['description'],
      'type'        => RULE_TYPES.index(rule['type']) + 1,
      'inverted'    => rule['inverted'],
      'value'       => rule['value'],
    }
  end

  def index_set_id_from_name(index_set_name)
    index_sets = get("system/indices/index_sets")['index_sets']
    index_set = if index_set_name
      index_sets.find {|set| set['title'] == index_set_name }
    else
      index_sets.find {|set| set['default'] }
    end
    index_set['id']
  end

end