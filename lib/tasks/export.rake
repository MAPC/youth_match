namespace :export do

  task :environment do
    require './environment'
    DATABASE_ENV = ENV['DATABASE_ENV'] || 'development'
    MIGRATIONS_DIR = ENV['MIGRATIONS_DIR'] || 'db/migrate'
  end

  desc 'Export positions'
  task positions: :environment do |t, args|
    file = "./tmp/exports/positions-#{Time.now.to_i}.csv"
    CSV.open(file, 'wb') do |csv|
      fields = %w( uuid category positions manual automatic street city state zip zip_5 )
      csv << fields # Header
      Position.find_each do |position|
        csv << fields.map { |field| position.send(field) }
      end
    end
  end

  desc 'Export placements for mail merge'
  task :mailmerge, [:run_id] => [:environment] do |t, args|
    pre_message(t)
    ExportJob.new(args[:run_id]).perform!
    $logger.info '----> DONE'
  end

  desc 'Export manual market applicants'
  task manapp: :environment do |t, args|
    pre_message(t)
    file = "./tmp/exports/manual-applicants-#{Time.now.to_i}.csv"
    CSV.open(file, 'wb') do |csv|
      csv << ['id']
      Applicant.where(market: :manual).find_each {|o| csv << [o.id] }
    end
  end

  desc 'Export manual market positions'
  task manpos: :environment do |t, args|
    pre_message(t)
    raise ArgumentError if Position.where(manual: nil).count > 0
    file = "./tmp/exports/manual-positions-#{Time.now.to_i}.csv"
    CSV.open(file, 'wb') do |csv|
      csv << ['id']
      Position.find_each do |o|
        o.manual.times { csv << [o.id] } # One row per manual position
      end
    end
  end



end
