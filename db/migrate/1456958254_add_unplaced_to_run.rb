class AddUnplacedToRun < ActiveRecord::Migration

  def change
    add_column :runs, :unplaced, :integer, array: true, default: []
  end

end
