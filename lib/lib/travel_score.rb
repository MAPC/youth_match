require_relative './score'

class TravelScore < Score

  def score
    time = TravelTime.find_by(
      input_id:  applicant.grid_id,
      target_id: position.grid_id,
      mode:      applicant.mode
    )
    # TODO put time into equation to get the score
  end

end
