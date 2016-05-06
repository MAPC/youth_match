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
    pre_message task
    ExportJob.new(args[:run_id]).perform!
    $logger.info '----> DONE'
  end

  desc 'Export manual market applicants'
  task manapp: :environment do |task, args|
    pre_message task
    file = "./tmp/exports/manual-applicants-#{Time.now.to_i}.csv"
    CSV.open(file, 'wb') do |csv|
      csv << ['id']
      Applicant.where(market: :manual).find_each {|o| csv << [o.id] }
    end
  end

  desc 'Export manual market positions'
  task manpos: :environment do |task, args|
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

  desc 'Export applicants for allocation'
  task appall: :environment do |task, args|
    pre_message task
    file = "./tmp/exports/applicants-#{Time.now.to_i}.csv"
    CSV.open(file, 'wb') do |csv|
      fields = %w( id uuid zip prefers_nearby has_transit_pass interests )
      csv << fields
      fields.pop # Remove interests

      Applicant.find_each do |applicant|
        begin
          interests = applicant.interests.join(';')
          attrs = fields.map { |field| applicant.send(field) }
          attrs.push interests # Add interests to end
          csv << attrs
        rescue StandardError => e
          puts "----> #{applicant.id}: #{e.message}"
          next
        end
      end
    end
  end

  desc 'Export positions for allocation'
  task posall: :environment do |task, args|
    pre_message task
    file = "./tmp/exports/positions-#{Time.now.to_i}.csv"
    CSV.open(file, 'wb') do |csv|
      fields = %w( uuid positions automatic manual zip_5 category reserve )
      csv << fields
      Position.find_each do |position|
        begin
          csv << fields.map { |field| position.send(field) }
        rescue StandardError => e
          puts "----> #{position.id}: #{e.message}"
          next
        end
      end
    end
  end

end
