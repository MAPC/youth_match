class AddAvailablePositionsToRun < ActiveRecord::Migration

  def change
    add_column :runs, :available_positions, :integer, array: true, null: false, default: []
  end

end
