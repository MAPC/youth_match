class DropBaseProportionField < ActiveRecord::Migration

  def change
    remove_column :pools, :base_proportion, :decimal
  end

end
