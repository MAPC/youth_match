require 'active_record'
require 'enumerize'
require 'yaml'
require 'activerecord-postgis-adapter'

Dir.glob('./lib/**/*.rb').each { |file| require file }

DB_ENV = ENV.fetch('DATABASE_ENV') { 'development' }

def config_from_yaml
  YAML.load_file('config/database.yml').fetch(DB_ENV) {
    raise StandardError, "No config for DATABASE_ENV #{DB_ENV.inspect}"
  }
end

@database_config = ENV.fetch('DATABASE_URL') { config_from_yaml }
ActiveRecord::Base.establish_connection(@database_config)
