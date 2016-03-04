class AddStatisticsFieldToRuns < ActiveRecord::Migration

  def change
    add_column :runs, :statistics, :json
  end

end
