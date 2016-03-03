namespace :match do

  task :environment do
    require_relative '../../environment'
    DATABASE_ENV = ENV['DATABASE_ENV'] || 'development'
    MIGRATIONS_DIR = ENV['MIGRATIONS_DIR'] || 'db/migrate'
  end

  desc 'Runs the matching process.'
  task run: :environment do
    $logger.debug "----> Running task `match:run` in #{DATABASE_ENV} environment."
    $logger.info '----> Running checks first'
    Rake::Task['match:check'].invoke
    begin
      MatchJob.new.perform!
    rescue
      $logger.error '----> FAIL: Task errored out.'
      $logger.error "----> #{e.message}"
      exit 1
    end
  end

  desc 'Ensure everything is in place before running the matching task.'
  task check: :environment do
    $logger.debug "----> Running task `match:check` in #{DATABASE_ENV} environment."
    begin
      CheckJob.new.perform!
      $logger.info "----> Checks all clear. Preparing for run."
    rescue StandardError => e
      $logger.error "----> Checks errored with error:\n\t#{e.message}"
    end
  end

  desc 'Statistics on how the matching process is going.'
  task stats: :environment do
    $logger.debug "----> Running task `match:stats` in #{DATABASE_ENV} environment."
    $logger.info '----> Checking statistics'
    $logger.error '----> FAIL: Not yet implemented'
    exit 1
  end

  desc 'Import applicants and positions CSV, which must be geocoded'
  task import: :environment do
    $logger.debug "----> Running task `match:import` in #{DATABASE_ENV} environment."
    begin
      ImportJob.new.perform!
    rescue ActiveRecord::RecordInvalid => e
      $logger.error "----> ERROR: #{e.inspect}\n\t#{e.record.inspect}"
      $logger.error '----> FAIL'
      exit 1
    end
  end

  desc 'Exports placements from a given run'
  # Run this as: `match:export[:id]`
  task :export, [:id] => [:environment] do |t, args|
    $logger.debug "----> Running task `match:export` in #{DATABASE_ENV} environment."
    $logger.info "----> Takes in an ID to export. (This run, id: #{args[:id]})"
    ExportJob.new(args[:id]).perform!
    $logger.error '----> FAIL: Not yet implemented'
    exit 1
  end

  desc 'List all of the runs, chronologically'
  task list: :environment do
    $logger.debug "----> Running task `match:list` in #{DATABASE_ENV} environment."
    ListJob.new.perform!
    $logger.info '----> DONE'
  end
end
