class Placement < ActiveRecord::Base
  extend Enumerize

  belongs_to :run
  belongs_to :applicant
  belongs_to :position

  validates :run,       presence: true
  validates :applicant, presence: true
  validates :position,  presence: true

  enumerize :status, in: [:potential, :accepted, :declined, :invalid],
    default: :potential, predicates: true

  def accept
    update_attribute :status, :accepted
  end

  def decline
    update_attribute :status, :declined
  end

  def invalidate
    update_attribute :status, :invalid
  end

  def expired
    return true if expiration.nil?
    expiration < Time.now
  end
  alias_method :expired?, :expired
end
