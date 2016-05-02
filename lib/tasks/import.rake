namespace :import do

  task :environment do
    require './environment'
    DATABASE_ENV = ENV['DATABASE_ENV'] || 'development'
    MIGRATIONS_DIR = ENV['MIGRATIONS_DIR'] || 'db/migrate'
  end

  desc 'Import applicants: initial import'
  task :applicants, [:limit, :offset, :continue] => :environment do |t, args|
    pre_message(t)
    importer = ApplicantCSVImporter.new
    importer.perform    # Load applicants from spreadsheet
    importer.geo_perform # Set locations and add grid IDs
  end

  desc 'Import positions: initial import'
  task :positions, [:limit, :offset, :continue] => :environment do |t, args|
    pre_message(t)
    PositionImporter.new(args).perform!
    PositionGeocoder.new.perform # Add locations for those not present
  end

  desc 'Import market allocations for positions'
  task markets: :environment do |t, args|
    pre_message(t)
    AllocatePositionsJob.new.perform!
  end

  desc 'Import market allocations and contact methods for applicants'
  task allocate: :environment do |t, args|
    pre_message(t)
    ApplicantAllocatorJob.new.perform
  end

  desc 'Import market allocations and contact methods for positions'
  task allocate_pos: :environment do |t, args|
    pre_message(t)
    PositionAllocatorJob.new.perform
  end

  desc 'Import applicants, initial, from Linda\'s spreadsheet'
  task csvapp: :environment do |t, args|
    pre_message(t)
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

end
