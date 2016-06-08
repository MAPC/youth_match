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

  desc 'Synchronize placements with ICIMS'
  task :sync, [:run_id, :dry_run, :limit, :offset] => :environment do |task, args|
    pre_message task

    opts = {
      run_id:  args.fetch(:run_id,  Run.last.id),
      dry_run: args.fetch(:dry_run, false).to_b,
      limit:   args.fetch(:limit,   nil),
      offset:  args.fetch(:offset,  nil)
    }
    puts "options: #{opts.inspect}"
    Synchronizer.new(opts).perform
  end

  desc 'Monitor the lottery as it runs'
  task :monitor, [:delay] => :environment do |task, args|
    pre_message task
    delay = args.fetch(:delay, 5)
    ContinuousMonitor.new(run_id: Run.last.id, delay: delay).monitor
  end

  desc 'Runs the matching process, in batches.'
  task :run, [:run_id, :limit] => :environment do |task, args|
    pre_message task
    run_id = args[:run_id]
    limit  = args[:limit]
    Rake::Task['prepare:declines'].invoke run_id
    LotteryRunner.new(run_id: run_id, limit: limit).perform!
  end

  desc 'Pulls in placements from ICIMS'
  task :cleanup, [:run_id, :limit, :offset] => :environment do |task, args|
    limit = (args[:limit] == 'none' ? nil : args[:limit])

    Run.find(args[:run_id]).placements.
      where.not(status: :pending).
      where.not(workflow_id: [0, nil]).
      limit(limit).
      offset(args[:offset]).
      each do |pl|
        puts "index #{pl.index}; id #{pl.id}"
        pl.pull!
    end
  end

end
