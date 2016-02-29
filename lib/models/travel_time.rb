class TravelTime < ActiveRecord::Base

  establish_connection $config.travel_time.to_h
  self.table_name = 'youthjobs.merged_swapped_all'

  def origin
    [y_origin, x_origin]
  end

  def destination
    [y_destination, x_destination]
  end

end
