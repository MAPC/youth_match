class MakeJobCategoriesArray < ActiveRecord::Migration

  def up
    change_column :positions, :category, :string, array: true, default: [], using: "(string_to_array(category, ','))"
    rename_column :positions, :category, :categories
  end

  def down
    rename_column :positions, :categories, :category
    change_column :positions, :category, :string, array: false
  end

end
