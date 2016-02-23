class AddExpirationToPlacement < ActiveRecord::Migration

  def change
    add_column :placements, :expiration, :datetime, null: true, default: 9.days.from_now
  end

end
