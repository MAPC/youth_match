namespace :export do

  desc 'Export positions'
  task positions: :environment do |task, args|
    pre_message task
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
  task :mailmerge, [:run_id] => [:environment] do |task, args|
    MailMergeExporter.new(args[:run_id]).perform!
  end

  namespace :manual do
    desc 'Export applicants with a manual market'
    task applicants: :environment do |task, args|
      pre_message task
      file = "./tmp/exports/manual-applicants-#{Time.now.to_i}.csv"
      CSV.open(file, 'wb') do |csv|
        csv << ['id']
        Applicant.where(market: :manual).find_each {|o| csv << [o.id] }
      end
    end

    desc 'Export positions with a manual market'
    task positions: :environment do |task, args|
      pre_message task
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

end
