require 'active_record'
require 'activerecord-postgis-adapter'
require 'descriptive_statistics/safe'
require 'enumerize'
require 'erb'
require 'logger'
require 'yaml'
require_relative './lib/refinements/ostructable'

def config_from_yaml
  config_file = File.read File.join(Dir.pwd, 'config', 'database.yml')
  YAML.load ERB.new(config_file).result
end

using Ostructable
$config = Hash.to_ostructs(config_from_yaml)

DB_ENV   = ENV.fetch('DATABASE_ENV') { 'development' }
database = ENV.fetch('DATABASE_URL') { $config.send(DB_ENV).to_h }

ActiveRecord::Base.establish_connection(database)

log_location = if ENV['LOG_FILE']
  File.new ENV['LOG_FILE']
else
  $stdout
end

$logger = Logger.new(log_location).tap do |log|
  log.progname = 'youth_match'
end

Dir.glob('./lib/**/*.rb').each { |file| require file }
