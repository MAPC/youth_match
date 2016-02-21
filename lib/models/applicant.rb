class Applicant < ActiveRecord::Base
  def self.random
    order('RANDOM()')
  end

  def interests
    Array(read_attribute(:interests))
  end

  def prefers_interest
    !prefers_nearby
  end
  alias_method :prefers_interest?, :prefers_interest
end
