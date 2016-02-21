namespace :match do

  task :environment do
    # require_relative '../../environment'
    DATABASE_ENV = ENV['DATABASE_ENV'] || 'development'
    MIGRATIONS_DIR = ENV['MIGRATIONS_DIR'] || 'db/migrate'
  end

  desc 'Runs the matching process.'
  task run: :environment do
    puts "----> Running task `match:run` in #{DATABASE_ENV} environment."
    puts '----> Can we get it so it runs the checks first?'
    puts '----> What is it, like, Rake::Task.invoke["name:of_task?"]'
    puts '----> FAIL: Not yet implemented'
    exit 1
  end

  desc 'Ensure everything is in place before running the matching task.'
  task check: :environment do
    puts "----> Running task `match:check` in #{DATABASE_ENV} environment."
    puts '----> Running checks'
    puts '----> Checking first item'
    puts '----> Checking second item'
    puts '----> Checking third item'
    puts '----> FAIL: Not yet implemented'
    exit 1
  end

  desc 'Statistics on how the matching process is going.'
  task stats: :environment do
    puts "----> Running task `match:stats` in #{DATABASE_ENV} environment."
    puts '----> Checking statistics'
    puts '----> FAIL: Not yet implemented'
    exit 1
  end

  desc 'Exports placements from a given run'
  # Run this as: `match:export[:id]`
  task :export, [:id] => [:environment] do |t, args|
    puts "----> Running task `match:export` in #{DATABASE_ENV} environment."
    puts "----> Takes in an ID to export. (This run, id: #{args[:id]})"
    puts '----> FAIL: Not yet implemented'
    exit 1
  end
end
