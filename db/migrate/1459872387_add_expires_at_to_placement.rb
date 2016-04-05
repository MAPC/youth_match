class AddExpiresAtToPlacement < ActiveRecord::Migration

  def change
    add_column :placements, :expires_at, :datetime, null: true
  end

end
