class AddStatusToPlacement < ActiveRecord::Migration

  def change
    add_column :placements, :status, :string, null: false, default: 'potential'
  end

end
