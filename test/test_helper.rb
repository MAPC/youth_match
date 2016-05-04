if ENV['CODECLIMATE_REPO_TOKEN']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end

require 'minitest/autorun'
require 'minitest/hell'
require 'minitest/focus'
require 'rack/test'
require 'webmock/minitest'
require 'active_record'
require 'database_cleaner'

DatabaseCleaner.strategy = :transaction

class Minitest::Spec
  before :each do
    DatabaseCleaner.start
  end
  after :each do
    DatabaseCleaner.clean
  end
end

MiniTest.after_run do
  WebMock.disable_net_connect!(allow: %w{ codeclimate.com })
end

ENV['DATABASE_ENV'] = 'test'
ENV['RACK_ENV'] = 'test'
ENV['ICIMS_API_KEY'] = ''
ENV['ICIMS_CUSTOMER_ID'] = '1234'
ENV['PROXY_URL'] = 'https://user:pass@subdomain.proxy.net:80'
ENV['AIRBRAKE_PROJECT_ID'] = 'test'
ENV['AIRBRAKE_KEY'] = 'test'

require './environment'

# Load test support
Dir.glob('./test/support/**/*.rb').each { |f| require f }

# Silence the logger during tests.
$logger = Logger.new('/dev/null')
ActiveRecord::Base.logger = $logger

Typhoeus::Config.user_agent = 'test'
