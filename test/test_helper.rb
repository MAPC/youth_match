if ENV['CODECLIMATE_REPO_TOKEN']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end

ENV['DATABASE_ENV'] = 'test'
ENV['ICIMS_API_KEY'] = ''

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
  WebMock.disable_net_connect!(allow: %w{codeclimate.com})
end

require_relative '../environment'

# Silence the logger during tests.
$logger = Logger.new('/dev/null')
ActiveRecord::Base.logger = $logger
