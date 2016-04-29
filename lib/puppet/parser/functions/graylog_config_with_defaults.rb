module Puppet::Parser::Functions
  newfunction(:graylog_config_with_defaults, :type => :rvalue, :doc => <<-'ENDHEREDOC') do |args|
    Add defaults for missing keys.

    Example:
      $config = {'is_master' => true}
      $defaults = {'is_master' => false, 'plugin_dir' => 'plugins/'}

      $actual_config = graylog_config_with_defaults($config, $defaults)

      # $actual_config == {'is_master' => true, 'plugin_dir' => 'plugins/'}
    ENDHEREDOC

    config = args[0] || raise(Puppet::ParseError, 'first argument missing! (hash)')
    defaults = args[1] || raise(Puppet::ParseError, 'second argument missing! (hash)')

    unless config.is_a?(Hash)
      raise(Puppet::ParseError, 'first argument needs to be a hash!')
    end
    unless defaults.is_a?(Hash)
      raise(Puppet::ParseError, 'second argument needs to be a hash!')
    end

    config.clone.tap do |new_config|
      defaults.each do |key, value|
        next if new_config.has_key?(key)
        new_config[key] = value
      end
    end
  end
end
