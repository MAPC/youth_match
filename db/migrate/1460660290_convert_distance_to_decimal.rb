class ConvertDistanceToDecimal < ActiveRecord::Migration

  def up
    change_column :merged_swapped_all, :distance, :decimal
  end

  def down
    change_column :merged_swapped_all, :distance, :integer
  end

end
