class Compressor

  def initalize(pool)
    @applicant = pool.applicant
    @pooled_positions = pool.positions
    @run = pool.run
  end

  def config
    $config.lottery
  end

  def positions
    Position.where(citywide: true).
      order(:distance_from_applicant).
      limit(count)
  end

  def gain
    thresh = config.balancer_threshhold
    return 0 if pool.base_proportion > thresh

  end

  def equation(coefficient, x)
    (1.08 ** (60 - x)) - 1
  end

  def coefficient
    1 + (config.balancer_coefficient * 0.008)
  end
end
