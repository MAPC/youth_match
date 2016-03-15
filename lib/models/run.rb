class Run < ActiveRecord::Base
  extend Enumerize

  default_scope { order(:id) }

  has_many :placements, dependent: :destroy

  enumerize :status, in: [:fresh, :running, :failed, :succeeded],
    predicates: true, default: :fresh

  def successful_placements
    placements.where.not(position: nil)
  end

  def failed_placements
    placements.where(position: nil)
  end

  def running!
    self.update_attribute(:status, :running)
  end

  def failed!
    self.update_attribute(:status, :failed)
  end

  def succeeded!
    self.update_attribute(:status, :succeeded)
  end

  # private

  # def calculate_statistics
  #   # Do work to create a JSON blob analyzing what happened.
  # end
end
