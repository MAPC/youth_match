module DYEERedirect

  def self.to(action)
    action = action.to_sym
    [ url_for_action(action), status_for(action) ]
  end

  private

  def self.url_for_action(action)
    "http://youth.boston.gov/#{PATHS[action]}"
  end

  def self.status_for(action)
    # Temporary when error, permanent when selection
    action.to_sym == :error ? 307 : 308
  end

  PATHS = {
    accept:  'lottery-accepted',
    decline: 'lottery-declined',
    error:   'lottery-error',
    opt_out: 'opt-out',
    expired: 'lottery-expired-one',
    expired_opt_out: 'lottery-expired-two'
  }

end