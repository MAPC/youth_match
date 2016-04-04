class CreatePooledPositions < ActiveRecord::Migration

  def change
    create_table :pooled_positions do |t|
      t.references :pool, index: true
      t.references :position, index: true
      t.json :score, null: false, default: {}
    end
  end


end
