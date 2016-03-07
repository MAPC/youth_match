class ExportJob

  def initialize(id)
    if id
      @run = Run.find(id)
    else
      @run = Run.last
    end
  end

  def perform!
    file = "./tmp/exports/run-#{@run.id}-#{Time.now.to_i}.csv"
    CSV.open(file, 'wb') do |csv|
      csv << %w( placement_uuid applicant_id position_id applicant_uuid position_uuid )
      @run.placements.
           includes(:applicant, :position).
           order(:applicant_id).
           find_each do |p|
        v = [p.uuid, p.applicant_id, p.position_id,
                  p.applicant.uuid, p.position.try(:uuid)]
        csv << v
      end
    end

    geojson_file = "./tmp/exports/run-#{@run.id}-#{Time.now.to_i}.geojson"
    File.open(geojson_file, 'w') { |f|
      f.write(@run.statistics['geojson'].to_json)
    }
  end

end
