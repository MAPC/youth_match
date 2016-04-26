class ExportJob

  def initialize(run_id)
    @run = run_id ? Run.find(run_id) : Run.last
  end

  def perform!
    first = @run.exportable_placements.first.index
    last  = @run.exportable_placements.last.index
    file = "./tmp/exports/mail-merge-run-#{@run.id}-from-#{first}-to-#{last}-#{Time.now.to_i}.csv"
    CSV.open(file, 'wb') do |csv|
      csv << header
      @run.exportable_placements.each { |placement| csv << values_for(placement) }
    end
  end

  private

  def header
    %w( applicant_id position_id accept_url decline_url opt_out_url contact_method last_chance )
  end

  def values_for(placement)
    [
      placement.applicant.id,
      placement.position.id,
      accept_url(placement),
      decline_url(placement),
      opt_out_url(placement),
      placement.applicant.contact,
      placement.last_chance?
    ]
  end

  def accept_url(placement)
    response_url placement, :accept
  end

  def decline_url(placement)
    response_url placement, :decline
  end

  def opt_out_url(placement)
    response_url placement, :opt_out
  end

  def response_url(placement, action)
    url = $config.lottery.placement_link.site.dup
    url << "/placements/#{placement.uuid}/#{action.to_s.dasherize}/?"
    url << "applicant_uuid=#{placement.applicant.uuid}&"
    url << "position_uuid=#{placement.position.uuid}"
    url
  end

end
