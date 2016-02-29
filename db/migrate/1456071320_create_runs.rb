class CreateRuns < ActiveRecord::Migration

  def change
    create_table :runs do |t|
      t.string :status, null: false, default: :fresh
      t.timestamps null: false
    end
  end

end
