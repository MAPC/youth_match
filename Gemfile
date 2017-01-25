source 'https://rubygems.org'

ruby '2.1.5'

# Database
gem 'activerecord'   # Database
gem 'activesupport'  # Inflectors, etc.
gem 'pg'             # Postgres
gem 'rgeo'
gem 'activerecord-postgis-adapter'
gem 'enumerize'

# Utilities
gem 'descriptive_statistics', '~> 2.4.0',
  require: 'descriptive_statistics/safe'
gem 'logger'
gem 'rounding'
gem 'naught'
gem 'wannabe_bool'
gem 'geocoder'

gem 'foreman'
gem 'dotenv'

# Working with APIs
gem 'typhoeus'
# gem 'retries', github: 'ooyala/retries'

# Web app
gem 'sinatra'
gem 'sinatra-activerecord'
gem 'haml'     # Template for frontend
gem 'airbrake' # Error notifications

group :test do
  gem 'minitest'       # Test framework
  gem 'minitest-focus' # One test at a time
  gem 'rack-test'
  gem 'database_cleaner'
  gem 'webmock', require: false # Ensure we don't query external services
  gem 'rb-fsevent', require: RUBY_PLATFORM.include?('darwin') && 'rb-fsevent'
  gem 'codeclimate-test-reporter' # Test coverage
  gem 'rake' # For Travis CI
end

group :development do
  gem 'guard'          # Autorun tests
  gem 'guard-minitest'
  gem 'rerun' # Reload web app on changes
  gem 'pry'
  gem 'pry-byebug'
end
