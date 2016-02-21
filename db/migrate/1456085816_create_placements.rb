class CreatePlacements < ActiveRecord::Migration

  def change
    create_table :placements do |t|
      t.uuid :uuid, null: false, default: 'uuid_generate_v4()'

      t.references :run,       null: false
      t.references :applicant, null: false
      t.references :position,  null: false

      t.timestamps null: false
    end
  end

end
