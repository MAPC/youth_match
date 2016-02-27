require_relative './score'

class TravelScore < Score

  def score
    travel_time = TravelTime.find_by(
      input_id:     @applicant.grid_id,
      target_id:    @position.grid_id,
      travel_mode:  @applicant.mode
    )
    # TODO put time into equation to get the score
    # Some kind of percentile ranking of travel times... this  
    # depends on the entire dataset.

    TravelTime.percentile_rank(&:time, time.travel_time)
  end

end
