require 'test_helper'

class ImportJobTest < Minitest::Test

  def job
    @_job ||= ImportJob.new
  end

  def test_default_directory
    assert_equal ['db', 'import'], job.directory
  end

  def test_takes_path_argument
    job_with_path = ImportJob.new('folder/file.ext')
    assert_equal ['folder', 'file.ext'], job_with_path.directory
  end

  def test_imports_applicants_from_spreadsheet_with_grid
    skip
    before_a, before_p = Applicant.count, Position.count
    # Stub the grid so it always returns, helping the validation pass.
    Grid.stub :intersecting_grid, Grid.new(g250m_id: 1) do
      ImportJob.new('test/fixtures/').perform!
    end
    after_a, after_p = Applicant.count, Position.count
    assert_equal 3, (after_a - before_a)
    assert_equal 3, (after_p - before_p)
  end

  def test_imports_applicants_from_spreadsheet_with_no_grid
    skip
    before_a, before_p = Applicant.count, Position.count
    assert_raises(ActiveRecord::RecordInvalid) {
      ImportJob.new('test/fixtures/').perform!
    }
    after_a, after_p = Applicant.count, Position.count
    assert_equal 0, (after_a - before_a)
    assert_equal 0, (after_p - before_p)
  end
end
