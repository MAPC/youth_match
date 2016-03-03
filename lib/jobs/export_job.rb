class ExportJob

  def initialize(id)
    @run = Run.find(id)
  end

  def perform!
    file = "./tmp/exports/run-#{@run.id}-#{Time.now.to_i}.csv"
    CSV.open(file, 'wb') do |csv|
      csv << %w( placement_uuid applicant_id position_id applicant_uuid position_uuid )
      @run.placements.includes(:applicant, :position).find_each do |p|
        values = [p.uuid, p.applicant_id, p.position_id,
                  p.applicant.uuid, p.position.uuid]
        csv << values
      end
    end
  end

end
