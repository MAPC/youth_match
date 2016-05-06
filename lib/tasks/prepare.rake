namespace :prepare do

  desc 'Prepare the matching process.'
  task :all, [:seed] => :environment do |task, args|
    pre_message task
    Rake::Task['prepare:run'].invoke(args[:seed])
    Rake::Task['prepare:pools'].invoke(Run.last.id)
  end

  desc 'Create run, placements.'
  task :run, [:seed] => :environment do |task, args|
    pre_message task
    RunPreparer.new(seed: args[:seed]).perform!
  end

  desc 'Calculate pools for every new placement.'
  task :pools, [:run_id] => :environment do |task, args|
    pre_message task
    PoolBuilder.new(run_id: args[:run_id]).perform!
  end

  desc 'Prepares for a second placement those applicants who declined.'
  task :declines, [:run_id] => :environment do |task, args|
    pre_message task
    ExpirationChecker.new(run_id: args[:run_id]).perform!
    DeclineRefresher.new(run_id: args[:run_id]).perform!
  end

end
