class AddConfigurationToRun < ActiveRecord::Migration

  def change
    add_column :runs, :config, :json, null: false, default: {}
  end

end
