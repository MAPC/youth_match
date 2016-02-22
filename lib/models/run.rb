class Run < ActiveRecord::Base

  has_many :placements, dependent: :destroy

  extend Enumerize

  enumerize :status, in: [:fresh, :running, :failed, :succeeded],
    default: :fresh

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
