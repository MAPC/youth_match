class AddMarketToApplicantAndPosition < ActiveRecord::Migration

  def change
    add_column :applicants, :market, :string, limit: 10
    add_column :positions,  :market, :string, limit: 10
  end

end
