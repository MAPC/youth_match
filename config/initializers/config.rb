require_relative '../initializers'
require './lib/refinements/ostructable'

module Initializers
  module Config

    using Ostructable

    def self.load
      $config = Hash.to_ostructs(config_from_yaml)
      coerce_config_types
    end

    private

    # If a DATABASE_URL is given for an environment, turn it into a string.
    # If not given, turn it into a Hash.
    # Yes, this is in large part reversing the ostructing above.
    # We live to optimize another day.
    def self.coerce_config_types
      %i( development test production ).each do |env|
        params = $config.send(env)
        if params.try(:url)
          $config.send("#{env}=", params.url)
        else
          $config.send("#{env}=", params.to_h)
        end
      end
    end

    def self.config_from_yaml
      config_file = File.read File.join(Dir.pwd, 'config', 'database.yml')
      YAML.load ERB.new(config_file).result
    end

  end
end
