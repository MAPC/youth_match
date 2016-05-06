namespace :allocate do

  # rake allocate:applicants
  # rake allocate:positions

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

  # rake allocate:export:applicants
  # rake allocate:export:positions

  namespace :export do

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

end
