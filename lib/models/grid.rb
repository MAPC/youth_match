class Grid < ActiveRecord::Base
  self.table_name = 'youthjobs.grid'
  def self.config_from_yaml
    YAML.load_file('config/internal.yml').fetch("travel_time_development")
  end

  establish_connection(self.config_from_yaml)

end
