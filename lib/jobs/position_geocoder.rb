require 'geocoder'

class PositionGeocoder

  def perform
    Position.where(location: nil).each do |position|
      next if no_address(position)
      results = Geocoder.search position.addresses.first.to_a.join(' ')
      if results.any?
        position.location = point_from_results(results)
        position.save!
      end
      sleep 0.5
      puts "\n\n"
    end
  end

  private

  def point_from_results(results)
    r = results.first
    factory.point r.longitude, r.latitude
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
