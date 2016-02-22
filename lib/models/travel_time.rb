class TravelTime < ActiveRecord::Base
  self.table_name = 'full_dist_pairs'
  establish_connection "travel_time_development"
  
  def origin
    [y_origin, x_origin]
  end

  def destination
    [y_destination, x_destination]
  end

end
