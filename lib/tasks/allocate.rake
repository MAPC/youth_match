namespace :allocate do

  desc 'Import market allocations and contact methods for applicants'
  task applicants: :environment do |task, args|
    pre_message task
    ApplicantAllocator.new.perform
  end

  desc 'Import market allocations and contact methods for positions'
  task positions: :environment do |task, args|
    pre_message task
    PositionAllocator.new.perform
  end

end
