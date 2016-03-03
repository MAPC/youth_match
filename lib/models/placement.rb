class Placement < ActiveRecord::Base

  belongs_to :run
  belongs_to :applicant
  belongs_to :position

  validates :run,       presence: true
  validates :applicant, presence: true
  validates :position,  presence: true

  def travel_time
    TravelTime.where(target_id: position.grid_id, input_id: applicant.grid_id, travel_mode: applicant.mode).first.time
  end
end
