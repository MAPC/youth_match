class AddOpportunitiesAndIndexToPlacement < ActiveRecord::Migration

  def change
    add_column :placements, :opportunities, :json, null: false, default: {}
    add_column :placements, :index, :integer
  end

end
