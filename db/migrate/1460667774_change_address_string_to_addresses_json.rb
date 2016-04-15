class ChangeAddressStringToAddressesJson < ActiveRecord::Migration

  def change
    add_column    :applicants, :addresses, :json, null: false, default: {}
    add_column    :positions,  :addresses, :json, null: false, default: {}
    remove_column :applicants, :address,   :string
    remove_column :positions,  :address,   :string
  end

end
