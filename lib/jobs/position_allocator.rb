class PositionAllocator

  def perform
    CSV.foreach('./db/import/jobs_randomization.csv', headers: true) do |row|
      position = Position.find_by(uuid: row['uuid'])
      position.positions = row['positions'].to_i
      position.automatic = row['computer_placement'].to_i
      position.manual = row['manual_placement'].to_i
      position.save!
    end
  end

  def reset
    Position.find_each do |position|
      position.positions = 0
      position.automatic = nil
      position.manual    = nil
      position.save!
    end
  end

end
