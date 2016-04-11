class AlterPoolRelationships < ActiveRecord::Migration

  def up
    add_column :pools, :placement_id, :integer
    remove_column :pools, :applicant_id, :integer
    remove_column :pools, :run_id, :integer
  end

  def down
    add_column :pools, :applicant_id, :integer
    add_column :pools, :run_id, :integer
    remove_column :pools, :placement_id, :integer
  end

end
