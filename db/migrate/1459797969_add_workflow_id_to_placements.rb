class AddWorkflowIdToPlacements < ActiveRecord::Migration

  def change
    add_column :placements, :workflow_id, :integer, null: true
  end

end
