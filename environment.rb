require 'active_record'
require 'activerecord-postgis-adapter'
require 'descriptive_statistics/safe'
require 'enumerize'
require 'erb'
require 'logger'
require 'yaml'
require 'dotenv'
require './config/initializers.rb'

Dotenv.load
Initializers.load

autoload_paths = ['./lib/**/*.rb', './apps', './apps/*.rb']
Dir.glob(autoload_paths).each { |file| require file }
