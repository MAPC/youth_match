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

end
