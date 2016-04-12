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

  def compressor
    compressor ||= Compressor.new(@pool)
  end

  def test_signal_no_positions
    @pool.expect(:positions, [])
    Pool.stub :maximum, 90 do
      assert_equal 0, compressor.signal
    end
  end

  def test_signal_max_positions
    @pool.expect(:positions, mock_positions)
    Pool.stub :maximum, 3 do
      assert_equal 100, compressor.signal
    end
  end

  def test_expected_output_no_positions
    @pool.expect(:positions, [])
    Pool.stub :maximum, 90 do
      assert_equal 20, compressor.expected_output
    end
  end

  def test_expected_output_max_positions
    @pool.expect(:positions, mock_positions)
    Pool.stub :maximum, 3 do
      assert_equal 100, compressor.expected_output
    end
  end

  def test_gain_no_positions
    @pool.expect(:positions, [])
    Pool.stub :maximum, 90 do
      assert_equal 20, compressor.gain
    end
  end

  def test_position_gain_no_positions
    @pool.expect(:positions, [])
    Pool.stub :maximum, 90 do
      assert_equal 18, compressor.position_gain
    end
  end

  def test_gain_max_positions
    @pool.expect(:positions, mock_positions)
    Pool.stub :maximum, 3 do
      assert_equal 0, compressor.gain
    end
  end

  def test_position_gain_max_positions
    @pool.expect(:positions, mock_positions)
    Pool.stub :maximum, 3 do
      assert_equal 0, compressor.position_gain
    end
  end

  def test_compress_no_positions
    @pool.expect(:positions, [])
    @pool.expect(:positions, [])
    positions = 20.times.map { Position.create }
    Position.stub :compressible, TestRelation.new(positions) do
      Pool.stub :maximum, 90 do
        assert_equal 18, compressor.compress!
      end
    end
  ensure
    positions.each(&:destroy!)
  end

  def test_compress_max_positions
    @pool.expect(:positions, mock_positions)
    @pool.expect(:positions, mock_positions)
    Pool.stub :maximum, 3 do
      assert_equal 0, compressor.compress!
    end
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
