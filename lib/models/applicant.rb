require './lib/lib/locatable'
require './lib/lib/creatable_from_icims'

class Applicant < ActiveRecord::Base

  include Locatable
  include CreatableFromICIMS

  extend Enumerize

  before_validation :compute_grid_id, if: 'location.present?'
  before_save :assign_mode

  validates :grid_id, presence: true, if: 'location.present?'

  enumerize :status, in: [:pending, :activated, :onboarded, :opted_out],
    default: :pending, predicates: true

  def opted_out
    update_attribute(:status, :opted_out)
  end

  def mode
    if has_transit_pass_changed?
      convert_pass_to_mode
    else
      read_attribute :mode
    end
  end

  def interests
    Array(read_attribute(:interests))
  end

  def prefers_interest
    !prefers_nearby
  end
  alias_method :prefers_interest?, :prefers_interest

  private

  def convert_pass_to_mode
    has_transit_pass? ? 'transit' : 'walking'
  end

  def assign_mode
    self.mode = convert_pass_to_mode
  end

end
