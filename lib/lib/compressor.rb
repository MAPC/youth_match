class Compressor

  attr_reader :pool, :applicant, :run

  def initialize(pool)
    @pool = pool
    @applicant = @pool.applicant
    @run = @pool.run
    @pooled_positions = @pool.positions
  end

  def positions
    Position.available(@run).where(reserve: true).
      limit(gain).order('RANDOM()')
  end

  def gain
    return 0 if @pool.base_proportion > config.balancer_threshhold
    equation
  end

  private

  def config
    $config.lottery
  end

  def equation
    (coefficient ** (60 - @pool.base_proportion)) - 1
  end

  def coefficient
    1 + (config.balancer_coefficient * 0.0008)
  end
end
