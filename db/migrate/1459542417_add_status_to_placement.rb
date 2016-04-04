class AddStatusToPlacement < ActiveRecord::Migration

  def change
    add_column :placements, :status, :string, limit: 9, default: 'pending'
  end

end
