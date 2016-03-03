class CreateGrid < ActiveRecord::Migration

  def change
    create_table :grid do |t|
      t.st_polygon :geom, srid: 4326, geographic: true
      t.integer :g250m_id
      t.string :municipal
      t.integer :muni_id
    end
  end

end
