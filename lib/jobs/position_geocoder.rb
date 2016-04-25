def PositionGeocoder

  def perform
    data = {}
    Position.where(location: nil).each do |position|
      results = Geocoder.search position.address.to_a.join(' ')
      if results.any?
        position.location = point_from_results(results)
        position.save!
      end
      sleep 0.5
    end
  end

  private

  def point_from_results(results)
    r = results.first
    factory.point r.longitude, r.latitude
  end

end
