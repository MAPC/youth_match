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

# If we want fixtures, start here:
# ActiveRecord::Base.establish_connection
# Test::Unit::TestCase.use_instantiated_fixtures = false
# Test::Unit::TestCase.use_transactional_fixtures = true
# Test::Unit::TestCase.fixture_path = File.join(File.dirname(__FILE__), 'fixtures')

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
$logger = NullLogger.new # Silence the logger during tests.
