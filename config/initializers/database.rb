%w( yaml erb active_record ).each { |f| require f }
require_relative '../initializers'
require_relative './config'

module Initializers
  module Database

    def self.connect(tries: 2)
      db = $config.send(environment)
      ActiveRecord::Base.establish_connection(db)
    rescue => e
      puts "retrying after error: #{e.inspect}"
      tries -= 1
      Initializers::Config.load
      retry if tries > 0
      raise
    end

    def self.load
      connect
    end

    def self.environment
      ENV.fetch('DATABASE_ENV') { 'development' }
    end

  end
end
