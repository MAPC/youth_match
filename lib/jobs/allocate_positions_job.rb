class AllocatePositionsJob

  def perform!
    CSV.foreach('./db/import/position-allocation.csv', headers: true) do |row|
      Position.find_by(uuid: row['uuid']).update_attributes(
        manual:    row['manual_placement'],
        automatic: row['computer_placement']
      )
    end
  end
end
