class ApplicantCSVImporter

  def perform
    files.each do |file|
      CSV.foreach(file, headers: true) do |row|
        next if duplicate_id?(system_id(row))
        Applicant.create! create_from_row(row)
      end
    end
  end

  def duplicate_id?(id)
    if Applicant.find_by(id: id)
      $logger.debug "Duplicate with ID #{id}"
      return true
    end
  end

  def files
    Dir.glob("#{csv_dir}/*.csv")
  end

  def csv_dir
    './db/import/query_results/csv'
  end

  def create_from_row(row)
    {
      id:               system_id(row),
      interests:        interests(row),
      prefers_nearby:   preference(row),
      has_transit_pass: transit_pass(row)
    }
  end

  def system_id(row)
    row['system_id'].to_i.to_s
  end

  def interests(row)
    row['interests']
  end

  def preference(row)
    row['preference'] == 'Close to me'
  end

  def transit_pass(row)
    row['transit_pass'] == 'Yes'
  end

  def geo_perform
    geo_files.each do |file|
      CSV.foreach(file, headers: true) do |row|
        Applicant.find(system_id(row)).update_attributes(geo(row))
      end
    end
  end

  def geo(row)
    {
      addresses: addresses(row),
      location: location(row)
    }
  end

  def addresses(row)
    [
      {
        street_address: row['address_clean'],
        city: row['city'],
        state: row['state'],
        zip: row['zip_clean']
      }
    ]
  end

  def location(row)
    factory.point(row['longitude'], row['latitude'])
  end

  def factory
    RGeo::Geographic.spherical_factory srid: 4326
  end

  def geo_dir
    './db/import/query_results/anonymized/geocoded'
  end

  def geo_files
    files = Dir.glob("#{geo_dir}/*.csv")
    files.shift # get rid of first, duplicate CSV
    files
  end

end
