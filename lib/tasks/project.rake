namespace :match do

  task :environment do
    require_relative '../../environment'
    DATABASE_ENV = ENV['DATABASE_ENV'] || 'development'
    MIGRATIONS_DIR = ENV['MIGRATIONS_DIR'] || 'db/migrate'
  end

  desc 'Runs the matching process.'
  task run: :environment do
    $logger.info "----> Running task `match:run` in #{DATABASE_ENV} environment."
    $logger.info '----> Can we get it so it runs the checks first?'
    $logger.info '----> What is it, like, Rake::Task.invoke["name:of_task?"]'
    $logger.error '----> FAIL: Not yet implemented'
    exit 1
  end

  desc 'Ensure everything is in place before running the matching task.'
  task check: :environment do
    $logger.info "----> Running task `match:check` in #{DATABASE_ENV} environment."
    $logger.info '----> Running checks'
    $logger.info '----> Checking first item'
    $logger.info '----> Checking second item'
    $logger.info '----> Checking third item'
    $logger.error '----> FAIL: Not yet implemented'
    exit 1
  end

  desc 'Statistics on how the matching process is going.'
  task stats: :environment do
    $logger.info "----> Running task `match:stats` in #{DATABASE_ENV} environment."
    $logger.info '----> Checking statistics'
    $logger.error '----> FAIL: Not yet implemented'
    exit 1
  end

  desc 'Import applicants and positions CSV, which must be geocoded'
  task import: :environment do
    $logger.info "----> Running task `match:import` in #{DATABASE_ENV} environment."
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
    $logger.info "----> Running task `match:export` in #{DATABASE_ENV} environment."
    $logger.info "----> Takes in an ID to export. (This run, id: #{args[:id]})"
    ExportJob.new(args[:id]).perform!
    $logger.error '----> FAIL: Not yet implemented'
    exit 1
  end

  desc 'List all of the runs, chronologically'
  task list: :environment do
    $logger.info "----> Running task `match:list` in #{DATABASE_ENV} environment."
    ListJob.new.perform!
    $logger.info '----> DONE'
  end
end
