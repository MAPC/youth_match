require_relative '../initializers'
require './lib/refinements/ostructable'

module Initializers
  module Config

    using Ostructable

    def self.load
      $config = Hash.to_ostructs(config_from_yaml)
      %i( development test production ).each do |env|
        params = $config.send(env)
        if params.try(:url)
          $config.send("#{env}=", params.url)
        else
          $config.send("#{env}=", params.to_h)
        end
      end
      puts "====> #{$config.inspect}"
    end

    private

    def self.config_from_yaml
      config_file = File.read File.join(Dir.pwd, 'config', 'database.yml')
      YAML.load ERB.new(config_file).result
    end

  end
end
