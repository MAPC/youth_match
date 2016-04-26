require 'test_helper'

class ExportJobTest < Minitest::Test

  def setup
    @run ||= Minitest::Mock.new
    2.times { @run.expect :id, 1 }
    3.times { @run.expect :exportable_placements, mock_placements }
  end

  def test_perform
    CSV.stub(:open, nil, mock_csv = StringIO.new) do
      Run.stub :find, @run do
        ExportJob.new(@run.id).perform!
      end
    end
    assert_equal expected_string.strip, mock_csv.string.strip
  end

  private

  def expected_string
    File.read('./test/fixtures/files/test_csv')
  end

  def mock_placements
    [
      OpenStruct.new(
        id: 1,
        uuid: 'f58b1019-77b0-4d44-a389-b402bb3e6d50',
        applicant: Applicant.new(uuid: 'f58b1019-77b0-4d44-a389-b402bb3e6d50'),
        position: Position.new(uuid: 'f58b1019-77b0-4d44-a389-b402bb3e6d50')
      ),
      OpenStruct.new(
        id: 1,
        uuid: 'f58b1019-77b0-4d44-a389-b402bb3e6d50',
        applicant: Applicant.new(uuid: 'f58b1019-77b0-4d44-a389-b402bb3e6d50'),
        position: Position.new(uuid: 'f58b1019-77b0-4d44-a389-b402bb3e6d50')
      )
    ]
  end

end
