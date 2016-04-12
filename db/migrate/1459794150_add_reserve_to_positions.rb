class AddReserveToPositions < ActiveRecord::Migration

  def change
    add_column :positions, :reserve, :boolean, null: false, default: false
  end

end
