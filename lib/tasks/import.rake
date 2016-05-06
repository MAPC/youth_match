namespace :import do

  desc 'Import applicants: initial import'
  task :applicants, [:limit, :offset, :continue] => :environment do |task, args|
    pre_message task
    importer = ApplicantCSVImporter.new
    importer.perform    # Load applicants from spreadsheet
    importer.geo_perform # Set locations and add grid IDs
  end

  desc 'Import positions: initial import'
  task :positions, [:limit, :offset, :continue] => :environment do |task, args|
    pre_message task
    PositionImporter.new(args).perform!
    PositionGeocoder.new.perform # Add locations for those not present
  end

  desc 'Import market allocations for positions'
  task markets: :environment do |task, args|
    pre_message task
    AllocatePositionsJob.new.perform!
  end

  desc 'Import market allocations and contact methods for applicants'
  task allocate: :environment do |task, args|
    pre_message task
    ApplicantAllocatorJob.new.perform
  end

  desc 'Import market allocations and contact methods for positions'
  task allocate_pos: :environment do |task, args|
    pre_message task
    PositionAllocatorJob.new.perform
  end

  desc 'Import applicants, initial, from Linda\'s spreadsheet'
  task csvapp: :environment do |task, args|
    pre_message task
    CSV.foreach('./db/import/eligible_ids.csv', headers: true) do |row|
      id = row.fetch('id')
      next if Applicant.find_by(id: id)
      begin
        person = ICIMS::Person.find(id)
        if app = Applicant.create_from_icims(person)
          $logger.info "Created Applicant #{app.id}"
        end
      rescue KeyError => e
        $logger.error "Skipping #{id} because missing address."
      end
    end
  end

  # desc 'Import applicants and positions CSV, which must be geocoded'
  # task import: :environment do |task, args|
  #   pre_message task
  #   begin
  #     ImportJob.new.perform!
  #   rescue ActiveRecord::RecordInvalid => e
  #     $logger.error "----> ERROR: #{e.inspect}\n\t#{e.record.inspect}"
  #     $logger.error '----> FAIL'
  #     exit 1
  #   end
  # end

end
