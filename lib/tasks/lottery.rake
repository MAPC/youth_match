namespace :lottery do

  task :environment do
    require_relative '../../environment'
    DATABASE_ENV = ENV['DATABASE_ENV'] || 'development'
    MIGRATIONS_DIR = ENV['MIGRATIONS_DIR'] || 'db/migrate'
  end

  desc 'Runs the matching process.'
  task :run, [:limit] => :environment do |t, args|
    $logger.debug "----> Running task `lottery:run` in #{DATABASE_ENV} environment."
    $logger.info '----> Running checks first'
    Rake::Task['lottery:check'].invoke
    begin
      $logger.info '----> Starting match!'
      id = MatchJob.new.perform!(args[:limit])
      Rake::Task['lottery:stats'].invoke(id)
      # TODO: Move to controller action
      # Rake::Task['lottery:export'].invoke(id)
      $logger.info '----> DONE!!!'
    rescue StandardError => e
      $logger.error '----> FAIL: Task errored out.'
      $logger.error "----> #{e.message}"
      exit 1
    end
  end

  desc 'Ensure everything is in place before running the matching task.'
  task check: :environment do
    $logger.debug "----> Running task `lottery:check` in #{DATABASE_ENV} environment."
    begin
      CheckJob.new.perform!
      $logger.info "----> Checks all clear. Preparing for run."
    rescue StandardError => e
      $logger.error "----> Checks errored with error:\n\t#{e.message}"
    end
  end

  desc 'Info on how the matching process is going.'
  task progress: :environment do
    $logger.debug "----> Running task `lottery:progress` in #{DATABASE_ENV} environment."
    $logger.info  '----> Checking progress'
    $logger.error '----> FAIL: Not yet implemented'
    exit 1
  end

  desc 'Import applicants and positions CSV, which must be geocoded'
  task import: :environment do
    $logger.debug "----> Running task `lottery:import` in #{DATABASE_ENV} environment."
    begin
      ImportJob.new.perform!
    rescue ActiveRecord::RecordInvalid => e
      $logger.error "----> ERROR: #{e.inspect}\n\t#{e.record.inspect}"
      $logger.error '----> FAIL'
      exit 1
    end
  end

  desc 'Exports placements from a given run'
  # Run this as: `lottery:export[:id]`
  task :export, [:id] => [:environment] do |t, args|
    $logger.debug "----> Running task `lottery:export` in #{DATABASE_ENV} environment."
    $logger.debug "----> Takes in an ID to export. (This run, id: #{args[:id]})"
    ExportJob.new(args[:id]).perform!
    $logger.info '----> DONE'
  end

  desc 'List all of the runs, chronologically'
  task list: :environment do
    $logger.debug "----> Running task `lottery:list` in #{DATABASE_ENV} environment."
    ListJob.new.perform!
    $logger.info '----> DONE'
  end

  desc 'Generate statistics for a given run.'
  task :stats, [:id] => [:environment] do |t, args|
    $logger.debug "----> Running task `lottery:stats` in #{DATABASE_ENV} environment."
    $logger.debug "----> Takes in an ID to generate stats on. (This run, id: #{args[:id]})"
    StatsJob.new(args[:id]).perform!
  end
end
