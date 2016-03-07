class RemoveNullConstraintOnPlacementPosition < ActiveRecord::Migration

  def change
    change_column_null :placements, :position_id, true
  end

end
