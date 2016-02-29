class TravelTime < ActiveRecord::Base
  self.table_name = 'youthjobs.merged_swapped_all'

  def self.config_from_yaml
    YAML.load_file('config/internal.yml').fetch("travel_time_development")
  end

  establish_connection(self.config_from_yaml)
  
  def origin
    [y_origin, x_origin]
  end

  def destination
    [y_destination, x_destination]
  end

end
