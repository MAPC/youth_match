class AddPairIdToTravelTimes < ActiveRecord::Migration

  def change
    add_column :merged_swapped_all, :pair_id, :integer, null: false
  end

end
