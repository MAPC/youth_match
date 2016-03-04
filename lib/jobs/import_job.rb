require 'csv'

class ImportJob

  attr_reader :directory

  def initialize(directory = 'db/import')
    @directory = directory.split('/')
  end

  def perform!
    ActiveRecord::Base.transaction do
      $logger.info '----> Loading Applicants'
      load_applicants
      $logger.info '----> Loading Positions'
      load_positions
      $logger.info '----> DONE'
    end
  rescue StandardError => e
    $logger.error '----> Rolling back changes.'
    $logger.error "----> Error: #{e.message} #{e.try(:record).inspect}"
  end

  private

  def load_applicants
    file = assert_file('applicants.csv')
    CSV.foreach(file, headers: true) do |row|
      location = factory.point(row['X'], row['Y'])
      params = {
        interests: [row['interest1'], row['interest2'], row['interest3']],
        prefers_nearby:   row[6],
        has_transit_pass: row[7],
        location: location
      }
      Applicant.create! params
    end
  rescue ActiveRecord::RecordInvalid
  end

  def load_positions
    file = assert_file 'positions.csv'
    CSV.foreach(file, headers: true) do |row|
      params = { category: row['category'], location: factory.point(row['X'], row['Y']) }
      Position.create! params
    end
  end

  def factory
    RGeo::Geographic.spherical_factory srid: 4326
  end

  def default_dir
    File.join Dir.pwd, 'db', 'import'
  end

  def assert_file(filename)
    file = File.join(@directory, filename)
    raise ArgumentError, "File does not exist: #{file}" unless File.exist?(file)
    file
  end
end
