require 'yaml'
require 'logger'
require 'active_record'
require 'active_support/inflector'

namespace :db do
  def create_database config
    create_db = lambda do |config|
      # Establish connection, but not to the database in use, by setting db: nil
      ActiveRecord::Base.establish_connection config.merge('database' => nil)
      ActiveRecord::Base.connection.create_database config['database']
      # Then, establish the conection
      ActiveRecord::Base.establish_connection config
    end

    begin
      create_db.call config
    rescue StandardError => sqlerr
      puts "ERROR CREATING DATABASE: #{sqlerr.message}"
    end
    puts "----> Created database #{config['database']}"
  end

  def template(file_name)
    "class #{file_name.camelize} < ActiveRecord::Migration\n\n  def up\n  end\n\n  def down\n  end\n\nend"
  end

  task :configuration => :environment do
    @config = YAML.load_file('config/database.yml')[DATABASE_ENV]
  end

  task :configure_connection => :configuration do
    ActiveRecord::Base.establish_connection @config
    ActiveRecord::Base.logger = Logger.new STDOUT if @config['logger']
  end

  desc 'Create the database from config/database.yml for the current DATABASE_ENV'
  task :create => :configure_connection do
    create_database @config
  end

  desc 'Drops the database for the current DATABASE_ENV'
  task :drop => :configure_connection do
    ActiveRecord::Base.establish_connection @config.merge('database' => nil)
    ActiveRecord::Base.connection.drop_database @config['database']
  end

  desc 'Migrate the database (options: VERSION=x, VERBOSE=false).'
  task :migrate => :configure_connection do
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate MIGRATIONS_DIR, ENV['VERSION'] ? ENV['VERSION'].to_i : nil
  end

  desc 'Rolls the schema back to the previous version (specify steps w/ STEP=n).'
  task :rollback => :configure_connection do
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1
    ActiveRecord::Migrator.rollback MIGRATIONS_DIR, step
  end

  desc "Retrieves the current schema version number"
  task :version => :configure_connection do
    puts "Current version: #{ActiveRecord::Migrator.current_version}"
  end

  desc 'Generate an empty migration file'
  task migration: :environment do
    file_name = ARGV[1]
    if file_name.nil?
      puts '----> Need a file name (like "create_resource")'
      exit 1
    end
    time = Time.now.to_i
    File.open("#{MIGRATIONS_DIR}/#{time}_#{file_name}.rb", 'w') { |f|
      f.write template(file_name)
    }
    exit 0
  end
end
