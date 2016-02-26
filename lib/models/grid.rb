class Grid < ActiveRecord::Base

  self.table_name = 'youthjobs.grid'

  def self.config_from_yaml
    YAML.load_file('config/internal.yml').fetch("travel_time_development")
  end

  establish_connection(self.config_from_yaml)

  def travel_times
    TravelTime.where(input_id: self.g250m_id)
  end

  def self.intersecting_grid(location: )
    # consider http://www.rubydoc.info/github/dazuma/rgeo/RGeo/Feature/Geometry#relate%3F-instance_method
    self.where('ST_Intersects(geom, :point)', point: location).first
  end

end
