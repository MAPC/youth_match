class MaskedCoordinates

  # MaskedCoordinates adds a small amount of noise to the given array of
  # coordinates, to hide the original location. This is similar to the
  # 'What They See' image describing Strava's Privacy Zones at
  #
  # https://support.strava.com/hc/en-us/articles/216918777-Privacy-Settings#zones
  #
  # Options:
  #
  # min:: Minimum amount of noise. At present, at least 0.03 will be added to or
  #       or substracted from each coordinate.
  #
  # max:: Maximum amount of noise. At present, no more than 0.05 will be added
  #       to or substracted from each coordinate.
  #
  # [allow_negatives]
  #   If true (the default), the mask can add OR subtract the random value from
  #   each coordinate.
  #
  # Given a coordinate of 0, with these defaults, the mask could return
  # values from -0.005 through -0.003 and 0.003 through 0.005.

  def initialize(coordinates, options={})
    @unmasked = coordinates
    @options = options
    @min = @options.fetch(:min) { 0.003 } # Minimum amount of noise
    @max = @options.fetch(:max) { 0.005 } # Maximum amount of noise
    @allow_negatives = @options.fetch(:allow_negatives) { true }
  end

  def coordinates
    @unmasked.map { |coor| coor + (mask_amount * mask_direction) }
  end

  # Select a random number from the minimum range value to the maximum.
  def mask_amount
    rand(@min..@max)
  end

  def mask_direction
    @allow_negatives ? [+1, -1].sample : +1
  end

end
