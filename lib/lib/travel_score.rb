require_relative './score'

class TravelScore < Score

  def score
    minutes = travel_time.to_i / 60
    assert_positive(minutes)
    if @applicant.prefers_nearby?
      care(minutes)
    else
      dont_care(minutes)
    end
  end

  private

  def travel_time
    @travel_time ||= TravelTime.find_by(
      input_id:     @applicant.grid_id,
      target_id:    @position.grid_id,
      travel_mode:  @applicant.mode
    ).time
  end

  def care(x)
    if x < 30
      (0.008 * (x ** 2)) - (0.5833 * x) + 5
    else
      -5
    end
  end

  def dont_care(x)
    if x < 40
      (-0.25 * x) + 5
    else
      -5
    end
  end

  def assert_positive(num)
    if num.to_f < 0
      raise ArgumentError, 'travel time must be > 0'
    end
  end

end
