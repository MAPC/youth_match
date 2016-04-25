class AddIndexToApplicants < ActiveRecord::Migration

  def change
    add_column :applicants, :index, :integer
  end

end
