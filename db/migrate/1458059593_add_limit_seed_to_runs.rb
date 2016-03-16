class AddLimitSeedToRuns < ActiveRecord::Migration

  def change
    add_column :runs, :seed,  :integer, limit: 4
    add_column :runs, :limit, :integer, limit: 6
  end

end
