class AddCompressedAttributeToPooledPositions < ActiveRecord::Migration

  def change
    add_column :pooled_positions, :compressed, :boolean, null: false, default: false
  end

end
