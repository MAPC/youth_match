namespace :import do

  task :environment do
    require './environment'
    DATABASE_ENV = ENV['DATABASE_ENV'] || 'development'
    MIGRATIONS_DIR = ENV['MIGRATIONS_DIR'] || 'db/migrate'
  end

  desc 'Import applicants: initial import'
  task :applicants, [:limit, :offset, :continue] => :environment do |t, args|
    ApplicantImporter.new(args).perform!
  end

  desc 'Import positions: initial import'
  task :positions, [:limit, :offset, :continue] => :environment do |t, args|
    PositionImporter.new(args).perform!
  end

  desc 'Import market allocations for positions'
  task markets: :environment do |t, args|
    pre_message(t)
    AllocatePositionsJob.new.perform!
  end

end
