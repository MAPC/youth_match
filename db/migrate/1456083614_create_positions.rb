class CreatePositions < ActiveRecord::Migration

  def change
    create_table :positions do |t|
      t.string :category
      t.uuid :uuid, null: false, default: 'uuid_generate_v4()'
      t.timestamps null: false
    end
  end

end
