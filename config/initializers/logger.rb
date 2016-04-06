require_relative '../initializers'

module Initializers
  module Logger

    def self.configure
      $logger = ::Logger.new(location).tap do |log|
        log.progname = progname
      end
    end

    def self.load
      configure
    end

    private

    def self.location
      ENV['LOG_FILE'] ? File.new(ENV['LOG_FILE']) : $stdout
    end

    def self.progname
      ENV['LOG_PROGNAME'] || 'youth_match'
    end

  end
end
