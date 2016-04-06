class AddStatusToApplicant < ActiveRecord::Migration

  def change
    add_column :applicants, :status, :string, limit: 10, default: 'pending'
  end

end
