require_relative '../initializers'
require './lib/refinements/ostructable'

module Initializers
  module Config

    using Ostructable

    def self.load
      $config = Hash.to_ostructs(config_from_yaml)
    end

    private

    def self.config_from_yaml
      config_file = File.read File.join(Dir.pwd, 'config', 'database.yml')
      YAML.load ERB.new(config_file).result
    end

  end
end
