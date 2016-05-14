class ContinuousMonitor

  def initialize(run_id: , delay: 5)
    @run = Run.find(run_id)
    @delay = delay
  end

  def monitor
    log_start
    loop do
      begin
        $logger.info stats
        $logger.info counts
        $logger.info "#{Pool.count} pools"
        sleep @delay
      rescue StandardError => e
        puts e.message
        log_finish
        break
      end
    end
  end

  private

  def stats
    {
      successful_placements: successful_placements.count,
      around_index: successful_placements.maximum(:index)
    }
  end

  def successful_placements
    @run.placements.where.not(position: nil)
  end

  def log_start
    @old_level = $logger.level
    $logger.level = Logger::INFO
    $logger.debug 'This message should not appear.'
  end

  def log_finish
    puts 'Exiting...'
    $logger.level = @old_level
    $logger.debug 'Log level set to debug'
  end

  def placements
    @run.placements.where(market: :automatic).
      where(status: [:placed, :synced])
  end

  def counts
    data = {
      expired:  count(:expired),
      accepted: count(:accepted),
      declined: count(:declined),
      placed:   count(:placed),
      synced:   count(:synced),
      pending:  count(:pending)
    }
    data.each_pair do |k,v|
      puts " #{k}:\t#{v}"
    end
    data
  end

  def count(status)
    placements.unscope(where: :status).where(status: status).count
  end


end
