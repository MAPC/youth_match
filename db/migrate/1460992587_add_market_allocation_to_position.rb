class AddMarketAllocationToPosition < ActiveRecord::Migration

  def change
    add_column :positions, :manual,    :integer, null: true, default: nil
    add_column :positions, :automatic, :integer, null: true, default: nil
  end

end
