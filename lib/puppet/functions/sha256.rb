require 'digest'

Puppet::Functions.create_function(:'graylog::sha256') do
  dispatch :sha256 do
    param 'String', :input
    return_type 'String'
  end

  def sha256(input)
    Digest::SHA256.hexdigest(input.chomp)
  end
end