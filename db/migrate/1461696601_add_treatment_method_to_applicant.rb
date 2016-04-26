class AddTreatmentMethodToApplicant < ActiveRecord::Migration

  def change
    add_column :applicants, :contact, :string, limit: 5
  end

end
