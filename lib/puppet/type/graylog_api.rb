require 'puppet/provider/graylog_api'
require 'pry'

Puppet::Type.newtype(:graylog_api) do

  newparam(:name) do
    desc "must be 'api'"
    newvalues('api')
  end

  newproperty('password') do
    desc 'the api password'
    isrequired

    def retrieve
      "password"
    end

    def should_to_s(newvalue)
      "password"
    end

    def is_to_s(value)
      "password"
    end

    def insync?(is)
      Puppet::Provider::GraylogAPI.api_password = @should.first
      true
    end
  end

  newproperty('port') do
    desc 'the api port'
    isrequired

    def retrieve
      "port"
    end

    def insync?(is)
      Puppet::Provider::GraylogAPI.api_port = @should.first
      true
    end
  end

end