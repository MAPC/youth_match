require_relative 'app'

set :environment, ENV.fetch('DATABASE_ENV') { 'development' }
set :run, false
set :raise_errors, true
