Dir[File.expand_path('lib/**/*.rake')].each { |f| load(f) }

def pre_message(task)
  $logger.debug "Running task `#{task.name}` in #{DATABASE_ENV} environment."
end

task :environment do
  require './environment'
  DATABASE_ENV   ||= ENV.fetch('DATABASE_ENV')   { 'development' }
  MIGRATIONS_DIR ||= ENV.fetch('MIGRATIONS_DIR') { 'db/migrate'  }
end
