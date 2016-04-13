class AddBackCategoryToPosition < ActiveRecord::Migration

  def change
    add_column :positions, :category, :string
  end

end
