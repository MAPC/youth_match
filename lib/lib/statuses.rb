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

    def self.activated
      'C38354'
    end

    def self.placed
      'C38356'
    end

    def self.accepted
      'C36951'
    end

    def self.declined
      'C14661'
    end

    def self.expired
      'C38355'
    end

    def self.processing_appointment
      'C23505'
    end

    def self.send_to_onboard
      'C23504'
    end

    def self.hired
      'C2040'
    end

  end
end
