class ExportJob

  def initialize(id)
    @id = id
    assert_run
  end

  def perform!
    # Export CSV of placements,
    # including applicant.uuid and position.uuid
    raise NotImplementedError
  end

  private

  def assert_run
    # @run = Run.find(id)
  end

end
