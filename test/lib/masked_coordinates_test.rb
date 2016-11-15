require 'test_helper'

class MaskedCoordinatesTest < Minitest::Test

  UNMASKED_COORDINATES = [42.3322441, -71.0982959]

  def setup_defaults
    @masked = MaskedCoordinates.new(UNMASKED_COORDINATES)
  end

  def setup_with_default_overrides
    @masked = MaskedCoordinates.new(
      UNMASKED_COORDINATES,
      {min: 0.004, max: 0.0045, allow_negatives: false}
    )
  end

  def test_mask_amount
    setup_defaults
    value = @masked.mask_amount
    assert_equal true, between_min_and_max(value)
  end

  def test_mask_direction_returns_postive_or_negative_one
    setup_defaults
    assert_includes [1,-1], @masked.mask_direction
  end

  def test_mask_direction_returns_postive_one_only
    setup_with_default_overrides
    assert_equal +1, @masked.mask_direction
  end

  def test_coordinates_are_new
    setup_defaults
    refute_equal UNMASKED_COORDINATES, @masked.coordinates
  end

  private

  def between_min_and_max(value, allowed=nil)
    if allowed == :negatives
      between_values(value, [[+1, +1],[+1, -1],[-1, -1],[-1, +1]])
    else
      between_values(value, [[+1, +1]])
    end
  end

  def between_values(value, coefficient_pairs, max_min=[0.003,0.005])
    coefficient_pairs.each do |pair|
      return true if value.between? pair[0]*max_min[0], pair[1]*max_min[1]
    end
  end

end
