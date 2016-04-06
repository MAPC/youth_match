class AddPositionCountToPosition < ActiveRecord::Migration

  def change
    add_column :positions, :positions, :integer, null: false, default: 0
  end

end
