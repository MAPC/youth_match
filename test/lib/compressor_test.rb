require 'test_helper'

class CompressorTest < Minitest::Test

  def setup
    @pool = Minitest::Mock.new
    @pool.expect(:applicant, Applicant.new)
    # Without this stub, would be dependent on lottery.yml remaining constant,
    # which defeats the purpose of having configuration in the first place.
    YAML.stub :load_file, stubbed_yaml do
      @pool.expect(:run, Run.new)
    end
  end

  def teardown
    $max_pool_size = 0
  end

  def compressor
    compressor ||= Compressor.new(@pool)
  end

  def test_signal_no_positions
    @pool.expect(:pooled_positions, [])
    $max_pool_size = 90
    assert_equal 0, compressor.signal
  end

  def test_signal_max_positions
    @pool.expect(:pooled_positions, mock_positions)
    $max_pool_size = 3
    assert_equal 100, compressor.signal
  end

  def test_expected_output_no_positions
    @pool.expect(:pooled_positions, [])
    $max_pool_size = 90
    assert_equal 20, compressor.expected_output
  end

  def test_expected_output_max_positions
    @pool.expect(:pooled_positions, mock_positions)
    $max_pool_size = 3
    assert_equal 100, compressor.expected_output
  end

  def test_gain_no_positions
    @pool.expect(:pooled_positions, [])
    $max_pool_size = 90
    assert_equal 20, compressor.gain
  end

  def test_position_gain_no_positions
    @pool.expect(:pooled_positions, [])
    $max_pool_size = 90
    assert_equal 18, compressor.position_gain
  end

  def test_gain_max_positions
    @pool.expect(:pooled_positions, mock_positions)
    $max_pool_size = 3
    assert_equal 0, compressor.gain
  end

  def test_position_gain_max_positions
    @pool.expect(:pooled_positions, mock_positions)
    $max_pool_size = 3
    assert_equal 0, compressor.position_gain
  end

  def test_compress_no_positions
    skip "Some weird mock errors happening."
    @pool.expect(:pooled_positions, [])
    @pool.expect(:pooled_positions, [])
    # Not sure where these are coming from.
    @pool.expect(:is_a?, true, [Hash])
    @pool.expect(:is_a?, true, [Pool])
    positions = 20.times.map { Position.create }
    Position.stub :compressible, TestRelation.new(positions) do
      $max_pool_size = 90
      assert_equal 18, compressor.compress!
    end
  ensure
    Array(positions).each(&:destroy!)
  end

  def test_compress_max_positions
    3.times { @pool.expect(:pooled_positions, mock_positions) }
    @pool.expect(:id, 1)
    $max_pool_size = 3
    assert_equal 0, compressor.compress!
  end

  private

  def mock_positions
    3.times.map do
      m = Minitest::Mock.new
      m.expect(:available?, true, [Run])
    end
  end

  def stubbed_yaml
    {
      "score_multipliers" => { "interest"=>1, "travel"=>1 },
      "compressor" => { "threshhold"=>40, "ratio"=>2, "direction"=>"upward" }
    }
  end

  class TestRelation
    def initialize(objects)
      @objects = objects
    end

    def limit(int)
      @objects.first(int)
    end
  end

end
