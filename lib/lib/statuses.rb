module Status

  def self.pending
    'pending'
  end

  def self.placed
    'placed'
  end

  def self.synced
    'synced'
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

    CODES = {
      activated: 'C38354',
      placed:    'C38356',
      accepted:  'C36951',
      declined:  'C38469',
      expired:   'C38355',
      hired:     'C2040',
      send_to_onboard: 'C23504',
      processing_appointment: 'C23505'
    }.with_indifferent_access

    CODES.each_pair do |key, code|
      define_singleton_method key do
        CODES[key]
      end
    end

    def self.from_code(code)
      CODES.invert[code]
    end

  end
end
