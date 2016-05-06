namespace :lottery do

  desc 'Prepare the matching process'
  task :prepare, [:seed] => :environment do |task, args|
    Rake::Task['prepare:all'].invoke args[:seed]
  end

  desc 'Pre-flight checklist before running the lottery for the first time.'
  task :check, [:run_id] => :environment do |task, args|
    pre_message task
    run_id = args.fetch(:run_id, Run.last.id)
    LotteryChecker.new(run_id: run_id).perform!
  end

  desc 'Monitor the lottery as it runs'
  task :monitor, [:run_id] => :environment do |task, args|
    pre_message task
    run_id = args.fetch(:run_id, Run.last.id)
    ContinuousMonitor.new(run_id: run_id).perform!
  end

  desc 'Runs the matching process, in batches.'
  task :run, [:run_id, :limit] => :environment do |task, args|
    pre_message task
    run_id = args[:run_id]
    limit  = args[:limit]
    Rake::Task['prepare:declines'].invoke run_id
    LotteryRunner.new(run_id: run_id, limit: limit).perform!
  end

end
