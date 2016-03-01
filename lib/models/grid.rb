class Grid < ActiveRecord::Base

  self.table_name = 'grid'

  def travel_times
    TravelTime.where(input_id: self.g250m_id)
  end

  def self.intersecting_grid(location: )
    # consider http://www.rubydoc.info/github/dazuma/rgeo/RGeo/Feature/Geometry#relate%3F-instance_method
    self.where('ST_Intersects(geom, :point)', point: location).first
  end

end
