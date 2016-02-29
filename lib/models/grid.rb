class Grid < ActiveRecord::Base

  establish_connection $config.travel_time.to_h
  self.table_name = 'youthjobs.grid'

  def travel_times
    TravelTime.where(input_id: self.g250m_id)
  end

  def self.intersecting_grid(location: )
    # consider http://www.rubydoc.info/github/dazuma/rgeo/RGeo/Feature/Geometry#relate%3F-instance_method
    self.where('ST_Intersects(geom, :point)', point: location).first
  end

end
