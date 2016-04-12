namespace :lottery do

  task :environment do
    require_relative '../../environment'
    DATABASE_ENV = ENV['DATABASE_ENV'] || 'development'
    MIGRATIONS_DIR = ENV['MIGRATIONS_DIR'] || 'db/migrate'
  end

  desc 'Prepared the matching process, assigning tickets and calculating pool.'
  task :prepare, [:seed] => :environment do |t, args|
    pre_message(t)
    run = AssignTicketsJob.new(seed: args[:seed]).perform!
    PrecalculatePoolJob.new(run_id: run.id).perform!
  end

  desc 'Runs the matching process, in batches.'
  task :run_batch, [:run_id, :limit] => :environment do |t, args|
    pre_message(t)
    LotteryRunJob.new(run_id: args[:run_id], limit: args[:limit]).perform!
  end

  desc 'Prepares for a second round those applicants who declined.'
  task :refresh_declines, [:run_id] => :environment do |t, args|
    pre_message(t)
    RefreshDeclinedJob.new(run_id: args[:run_id]).perform!
  end

  desc 'Runs the matching process.'
  task :run, [:limit, :seed] => :environment do |t, args|
    pre_message(t)
    $logger.info '----> Running checks first'
    Rake::Task['lottery:check'].invoke
    begin
      $logger.info '----> Starting match!'
      id = MatchJob.new(limit: args[:limit], seed: args[:seed]).perform!
      Rake::Task['lottery:stats'].invoke(id)
      # TODO: Move to controller action
      # Rake::Task['lottery:export'].invoke(id)
      $logger.info '----> DONE!!!'
    rescue StandardError => e
      $logger.error '----> FAIL: Task errored out.'
      $logger.error "----> #{e.message}"
      $logger.error e.backtrace.join("\n")
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
  task :export, [:id] => [:environment] do |t, args|
    pre_message(t)
    $logger.debug "----> Takes in an ID to export. (This run, id: #{args[:id]})"
    ExportJob.new(args[:id]).perform!
    $logger.info '----> DONE'
  end

  private

  def pre_message(task)
    $logger.debug "----> Running task `#{task.name}` in #{DATABASE_ENV} environment."
  end

end
