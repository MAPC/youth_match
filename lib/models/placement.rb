class Placement < ActiveRecord::Base

  belongs_to :run
  belongs_to :applicant
  belongs_to :position

  validates :run,       presence: true
  validates :applicant, presence: true
  validates :position,  presence: true
end
