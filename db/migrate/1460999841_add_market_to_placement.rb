class AddMarketToPlacement < ActiveRecord::Migration

  def change
    add_column :placements, :market, :string, limit: 10, default: ''
  end

end
