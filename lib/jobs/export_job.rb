class ExportJob

  def initialize(run_id)
    @run = run_id ? Run.find(run_id) : Run.last
  end

  def perform!
    file = "./tmp/exports/mail-merge-#{@run.id}-#{Time.now.to_i}.csv"
    CSV.open(file, 'wb') do |csv|
      csv << header
      relevant_placements.each { |placement| csv << values_for(placement) }
    end
  end

  private

  def relevant_placements
    @run.placements.includes(:applicant, :position).
      order(:index). # Redundant with Placement.default_scope
      where(status: [:pending, :placed])
  end

  def header
    %w( placement_uuid applicant_id position_id applicant_uuid position_uuid )
  end

  def values_for(placement)
    [placement.uuid,
     placement.applicant_id,
     placement.position_id,
     placement.applicant.uuid,
     placement.position.try(:uuid)]
  end

end
