class CreatePositions < ActiveRecord::Migration

  def change
    create_table :positions do |t|
      t.string :category
      t.st_point :location, srid: 4326, geographic: true
      t.uuid :uuid, null: false, default: 'uuid_generate_v4()'
      t.integer :grid_id
      t.timestamps null: false
    end
  end

end
