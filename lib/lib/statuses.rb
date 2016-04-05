module Status

  def self.pending
    'pending'
  end

  def self.placed
    'placed'
  end

  def self.accepted
    'accepted'
  end

  def self.declined
    'declined'
  end

  def self.expired
    'expired'
  end

end


module ICIMS
  module Status

    def self.placed
      'PLACED'
    end

    def self.accepted
      'C36951'
    end

    def self.declined
      'C14661'
    end

  end
end
