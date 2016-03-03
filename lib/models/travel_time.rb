class TravelTime < ActiveRecord::Base

  self.table_name = 'merged_swapped_all'

  def origin
    [y_origin, x_origin]
  end

  def destination
    [y_destination, x_destination]
  end

end
