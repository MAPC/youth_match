require 'geocoder'

class PositionGeocoder

  def perform
    log_start
    locationless_positions.each do |position|
      next if no_address(position)
      results = Geocoder.search position.address.to_a.join(' ')
      if results.any?
        position.location = point_from_results(results)
        position.save!
      end
      sleep 0.5
    end
    log_finish
  end

  private

  def locationless_positions
    Position.where(location: nil)
  end

  def log_start
    @before = locationless_positions.count
    $logger.debug "#{@before} positions have no location"
  end

  def log_finish
    @after = locationless_positions.count
    $logger.debug "Found a location for #{@before - @after} positions."
    $logger.debug "#{@after} positions have no location"
  end

  def point_from_results(results)
    r = results.first
    factory.point r.longitude, r.latitude
  end

  def factory
    RGeo::Geographic.spherical_factory srid: 4326
  end

  def no_address(position)
    if position.addresses.first
      false
    else
      $logger.debug "No address for position #{position.id}"
      true
    end
  end

end
