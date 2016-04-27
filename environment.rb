require 'active_record'
require 'activerecord-postgis-adapter'
require 'descriptive_statistics/safe'
require 'enumerize'
require 'erb'
require 'logger'
require 'yaml'
require 'dotenv'
require 'wannabe_bool'
require './config/initializers.rb'

DATABASE_ENV = ENV['DATABASE_ENV'] || 'development'

Initializers.load
Dotenv.load if %w( development production ).include?(DATABASE_ENV)

autoload_paths = ['./lib/**/*.rb', './apps', './apps/*.rb']
Dir.glob(autoload_paths).each { |file| require file }
