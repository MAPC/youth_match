class CreatePools < ActiveRecord::Migration

  def change
    create_table :pools do |t|
      t.references :applicant, index: true
      t.references :run, index: true
      t.integer :position_count
      t.decimal :base_proportion
    end
  end

end
