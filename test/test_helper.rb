if ENV['CODECLIMATE_REPO_TOKEN']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end

ENV['DATABASE_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/hell'
require 'minitest/focus'
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

MiniTest::Unit.after_tests do
  WebMock.disable_net_connect!(allow: %w{codeclimate.com})
end

require_relative '../environment'
