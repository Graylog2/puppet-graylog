require 'rest-client'
require 'json'

class Puppet::Provider::GraylogAPI < Puppet::Provider

  class << self
    attr_accessor :api_password, :api_port

    def request(method,path,params={})
      api_password = Puppet::Provider::GraylogAPI.api_password
      api_port = Puppet::Provider::GraylogAPI.api_port
      case method
      when :get, :delete
        headers = {
          params: params,
          accept: :json,
        }
        payload = nil
      when :post, :put
        headers = {
          accept: :json,
          content_type: :json,
        }
        payload = params.to_json
      end
      result = RestClient::Request.execute(
        method: method,
        url: "http://localhost:#{api_port}/api/#{path}",
        user: 'admin',
        password: api_password,
        headers: headers,
        payload: payload,
      )
      JSON.parse(result.body) unless result.empty?
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

  [:request, :get, :put, :post, :delete, :symbolize].each do |m|
    method = self.method(m)
    define_method(m) {|*args| method.call(*args) }
  end

  def node_id
    get('/system')['node_id']
  end

end