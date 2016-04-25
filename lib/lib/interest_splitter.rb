module InterestSplitter

  def self.split(interests)
    possibilities.select { |possible| interests.include?(possible) }.sort
  end

  private

  def self.possibilities
    ["Admin or Office Assistant",
     "Art or Graphic Design",
     "Business or Entrepreneurship",
     "Child Care or Teacher's Assistant",
     "Community Organizing",
     "Construction or Building Trades",
     "Digital Media, Communications or Film",
     "Education or Tutoring",
     "Engineering and/or Math",
     "Environment, Natural Resources, and/or Agriculture",
     "Government, or Public Service",
     "Health Care",
     "Hospitality &amp; Tourism",
     "Hospitality & Tourism",
     "Human Services",
     "Information Technology",
     "Law",
     "Maintenance/Landscaping",
     "Other",
     "Peer Leadership",
     "Science",
     "Sports, Fitness and/or Recreation",
     "Technology",
     "Transportation",
     "Veterinary or Marine Science",
     "Visual or Performing Arts",
     "Theatre or Performing Arts"]
  end

end
