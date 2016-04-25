class Compressor

  attr_reader :pool, :applicant, :run

  def initialize(pool)
    @pool = pool
    @run = @pool.run
    @applicant = @pool.applicant
    # Only select those pooled positions that are still available for
    # placement, since we are doing the compression at runtime and need to
    # base the compression off of the available positions at the time the
    # applicant is addressed.
    @pooled_positions = @pool.pooled_positions.select { |p| p.available?(@run) }
  end

  def compress!
    new_positions = positions.map do |position|
      PooledPosition.create(compressed: true, position: position, pool: @pool)
    end
    if new_positions.any?
      $logger.debug "Compressor: Started with #{@pool.position_count} pooled positions"
      $logger.debug "Compressor: Added #{new_positions.count} positions to pool
        #{@pool.id} for #{@pool.pooled_positions.count} pooled positions."
    end
    return new_positions.count
  end

  def positions
    Position.compressible(@run).limit(position_gain)
  end

  def position_gain
    (gain.to_f / 100) * max_pool_position_count
  end

  def gain
    if signal < threshhold
      expected_output - signal
    else
      0
    end
  end

  def expected_output
    if signal < threshhold
      threshhold + ((signal - threshhold) / ratio)
    else
      signal
    end
  end

  def signal
    @signal ||= @pooled_positions.count.to_f / max_pool_position_count * 100
  end

  private

  def threshhold
    config.fetch(:threshhold)
  end

  def ratio
    config.fetch(:ratio)
  end

  def config
    @run.config.fetch(:compressor)
  end

  def max_pool_position_count
    $max_pool_size ||= @run.placements.
      where(market: :automatic).map {|pl| pl.pool.position_count }.max
  end

end
