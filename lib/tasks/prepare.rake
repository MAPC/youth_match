namespace :prepare do

  task :environment do
    require './environment'
    DATABASE_ENV = ENV['DATABASE_ENV'] || 'development'
    MIGRATIONS_DIR = ENV['MIGRATIONS_DIR'] || 'db/migrate'
  end

  desc 'Prepare the matching process.'
  task :all, [:seed] => :environment do |t, args|
    Rake::Task['prepare:tickets'].invoke(args[:seed])
    Rake::Task['prepare:pools'].invoke(Run.last.id)
  end

  desc 'Prepare the matching process, assigning tickets.'
  task :tickets, [:seed] => :environment do |t, args|
    pre_message(t)
    AssignTicketsJob.new(seed: args[:seed]).perform!
  end

  desc 'Prepare the matching process, precalculating base job pools.'
  task :pools, [:run_id] => :environment do |t, args|
    pre_message(t)
    PrecalculatePoolJob.new(run_id: args[:run_id]).perform!
  end

  desc 'Prepares for a second placement those applicants who declined.'
  task :declines, [:run_id] => :environment do |t, args|
    pre_message(t)
    RefreshDeclinedJob.new(run_id: args[:run_id]).perform!
  end

  private

  def pre_message(task)
    $logger.debug "----> Running task `#{task.name}` in #{DATABASE_ENV} environment."
  end

end
