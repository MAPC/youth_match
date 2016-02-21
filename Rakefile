Dir[File.expand_path('lib/**/*.rake')].each{ |f| load(f) }

task :environment do
  DATABASE_ENV = ENV['DATABASE_ENV'] || 'development'
  MIGRATIONS_DIR = ENV['MIGRATIONS_DIR'] || 'db/migrate'
end
