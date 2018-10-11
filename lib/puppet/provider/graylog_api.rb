require 'httparty' if Puppet.features.httparty?
require 'json' if Puppet.features.json?

class Puppet::Provider::GraylogAPI < Puppet::Provider

  confine feature: :json
  confine feature: :httparty

  class << self
    attr_accessor :api_password, :api_port

    def request(method,path,params={})
      api_password = Puppet::Provider::GraylogAPI.api_password
      api_port = Puppet::Provider::GraylogAPI.api_port
      fail "No Graylog_api['api'] resource defined!" unless api_password && api_port # It would be nicer to do this in the Type, but I don't see how without writing it over and over again for each type.
      case method
      when :get, :delete
        headers = { 'Accept' => 'application/json' }
        query   = params
        body = nil
      when :post, :put
        headers = {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json',
        }
        body = params.to_json
        query = nil
      end
      begin
        Puppet.debug { "#{method.upcase} request for http://localhost:#{api_port}/api/#{path} with params #{params.inspect}" }
        result = HTTParty.send(
          method,
          "http://localhost:#{api_port}/api/#{path}",
          basic_auth: {
            username: 'admin',
            password: api_password,
          },
          headers: headers,
          query: query,
          body: body,
        )
        Puppet.debug("Got result #{result.body}")
      rescue HTTParty::ResponseError => e
        Puppet.send_log(:err, "Got error response #{e.response}")
        raise e
      end
      recursive_nil_to_undef(JSON.parse(result.body)) unless result.empty?
    end

    # Under Puppet Apply, undef in puppet-lang becomes :undef instead of nil
    def recursive_nil_to_undef(data)
      return data unless Puppet.settings[:name] == 'apply'
      case data
      when nil
        :undef
      when Array
        data.map {|item| recursive_nil_to_undef(item) }
      when Hash
        data.transform_values {|value| recursive_nil_to_undef(value) }
      else
        data
      end
    end

    # This intentionally only goes one layer deep
    def symbolize(hsh)
      Hash[hsh.map {|k,v| [k.to_sym,v] }]
    end

    def get(path,params={})
      request(:get,path,params)
    end

    def put(path,params={})
      request(:put,path,params)
    end

    def post(path,params={})
      request(:post,path,params)
    end

    def delete(path,params={})
      request(:delete,path,params)
    end

    def prefetch(resources)
      items = instances
      resources.each_pair do |name,resource|
        if provider = items.find { |item| item.name == name.to_s }
          resource.provider = provider
        end
      end
    end
  end

  attr_writer :rest_id

  def rest_id
    @rest_id || resource[:name]
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    @action = :create
  end

  def destroy
    @action = :destroy
  end

  # Under Puppet Apply, undef in puppet-lang becomes :undef instead of nil
  def recursive_undef_to_nil(data)
    return data unless Puppet.settings[:name] == 'apply'
    case data
    when :undef
      nil
    when Array
      data.map {|item| recursive_undef_to_nil(item) }
    when Hash
      data.transform_values {|value| recursive_undef_to_nil(value) }
    else
      data
    end
  end

  [:request, :get, :put, :post, :delete, :symbolize].each do |m|
    method = self.method(m)
    define_method(m) {|*args| method.call(*args) }
  end

  def node_id
    get('/system')['node_id']
  end

  def simple_flush(path,params)
    params = recursive_undef_to_nil(params)
    case @action
    when :destroy
      delete("#{path}/#{rest_id}")
    when :create
      response = post("#{path}",params)
      set_rest_id_on_create(response) if respond_to?(:set_rest_id_on_create)
    else
      put("#{path}/#{rest_id}",params)
    end
  end

end