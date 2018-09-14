require 'retries' if Puppet.features.retries?

Puppet::Type.type(:graylog_api).provide(:graylog_api) do

  confine feature: :retries

  def self.prefetch(resources)
    password = resources[:api][:password]
    port = resources[:api][:port]
    Puppet::Provider::GraylogAPI.api_password = password
    Puppet::Provider::GraylogAPI.api_port = port
    wait_for_api(port)
    resources[:api].provider = new({password: password, port: port})
  end

  def self.wait_for_api(port)
    Puppet.debug("Waiting for Graylog API")
    with_retries(max_tries: 60, base_sleep_seconds: 1, max_sleep_seconds: 1) do
      RestClient.head("127.0.0.1:#{port}")
    end
  rescue Errno::ECONNREFUSED
    fail("Graylog API didn't become available on port #{port} after 30 seconds")  
  end
end