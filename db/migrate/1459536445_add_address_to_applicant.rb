class AddAddressToApplicant < ActiveRecord::Migration

  def change
    add_column :applicants, :address, :string
  end

end
