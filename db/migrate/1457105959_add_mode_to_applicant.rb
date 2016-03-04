class AddModeToApplicant < ActiveRecord::Migration

  def change
    add_column :applicants, :mode, :string, limit: 15
  end

end
