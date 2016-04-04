require 'test_helper'

class CompressorTest < Minitest::Test

  def setup
    @pool = Minitest::Mock.new
    @pool.expect(:applicant, Applicant.new)
    @pool.expect(:run, Run.new)
  end

  def compressor
    compressor = Compressor.new(@pool)
  end

  def test_gain_no_positions
    @pool.expect(:base_proportion, 0)
    @pool.expect(:base_proportion, 0)
    @pool.expect(:positions, [])
    assert_in_delta 100, compressor.gain, 1
  end

  def test_gain_max_positions
    @pool.expect(:base_proportion, 100)
    @pool.expect(:positions, [1, 2, 3])
    Pool.stub :maximum, 3 do
      assert_in_delta 0, compressor.gain, 1
    end
  end

end
