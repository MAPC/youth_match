class PositionImporter

  attr_reader :limit, :offset

  def initialize(limit: nil, offset: 0, continue: true, directory: 'db/import')
    @limit = limit ? limit.to_i : nil
    @offset = offset.to_i
    @continue = continue.to_b
    @directory = directory.split('/')
  end

  def perform!
    file = assert_file 'positions.csv'
    CSV.foreach(file, headers: true) do |row|
      $logger.info row['category']
      params = { categories: [row['category']], location: factory.point(row['X'], row['Y']), automatic: 1, manual: 0 }
      $logger.info params
      Position.create! params
    end
  end

  def assert_file(filename)
    file = File.join(@directory, filename)
    raise ArgumentError, "File does not exist: #{file}" unless File.exist?(file)
    file
  end

  def skip_duplicate?(job)
    if j = Position.find_by(id: job.id)
      $logger.info "----> Skipping #{job.id} because Position #{j.id} exists"
      true
    end
  rescue
    false
  end

  def factory
    RGeo::Geographic.spherical_factory srid: 4326
  end

  def scope_opts
    { limit: @limit, offset: @offset }
  end

end
