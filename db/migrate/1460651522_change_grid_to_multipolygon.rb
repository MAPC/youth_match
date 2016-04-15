class ChangeGridToMultipolygon < ActiveRecord::Migration

  def up
    sql = "ALTER TABLE grid ALTER COLUMN geom TYPE geometry(MultiPolygon,4326) USING ST_Multi(geom::geometry)"
    ActiveRecord::Base.connection.execute sql
    # change_column :grid, :geom, 'MultiPolygon', srid: 4326, geographic: true
  end

  def down
    sql = "ALTER TABLE grid ALTER COLUMN geom TYPE geometry(Polygon,4326)"
    ActiveRecord::Base.connection.execute sql
    # change_column :grid, :geom, :st_polygon, srid: 4326, geographic: true
  end

end
