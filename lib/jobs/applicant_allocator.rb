class ApplicantAllocator

  def perform
    CSV.foreach('./db/import/applicant_randomization.csv', headers: true) do |row|
      applicant = Applicant.find row['system_id'].to_i
      applicant.contact = extract_contact(row)
      applicant.assign_attributes market_and_index(row)
      applicant.save
    end
  end

  def market_and_index(row)
    manual    = row['manual_lottery'].to_i
    automatic = row['computer_lottery'].to_i
    if manual > 0
      { market: :manual,    index: manual    }
    else
      { market: :automatic, index: automatic }
    end
  end

  def extract_contact(row)
    if row['treatment'].include? 'email'
      :email
    elsif row['treatment'].include? 'phone'
      :phone
    else
      raise ArgumentError,
        "#{row['treatment']} does not include 'phone' or 'email'"
    end
  end

end
