class MaskedCoordinates

  def initialize(coordinates, options={})
    @unmasked = coordinates
    @options = options
    @min = @options.fetch(:min) { 0.003 }
    @max = @options.fetch(:max) { 0.005 }
    @allow_negatives = @options.fetch(:allow_negatives) { true }
  end

  def coordinates
    [@unmasked, mask].transpose.map { |x| x.reduce(:+) }
  end

  def mask
    2.times.map { mask_amount * mask_direction }
  end

  def mask_amount
    rand(@min..@max)
  end

  def mask_direction
    if @allow_negatives
      rand > 0.5 ? +1 : -1
    else
      +1
    end
  end

end
