source 'https://rubygems.org'

ruby '2.1.5'


gem 'activerecord'   # Database
gem 'activesupport'  # Inflectors, etc.
gem 'pg'             # Postgres
gem 'rgeo'
gem 'activerecord-postgis-adapter'
gem 'enumerize'
gem 'foreman'
gem 'descriptive_statistics', '~> 2.4.0',
  require: 'descriptive_statistics/safe'
gem 'logger'
gem 'rounding'

# Web app
gem 'sinatra'
gem 'sinatra-activerecord'
gem 'haml'

group :test do
  gem 'minitest'       # Test framework
  gem 'minitest-focus' # One test at a time
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
end
