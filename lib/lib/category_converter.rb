module CategoryConverter

  def self.convert(category)
    if CONVERSIONS.keys.include?(category)
      CONVERSIONS[category]
    else
      category
    end
  end

  # Cannot convert back, because conversion is not one-to-one.
  # Thus, the job categories are canonical.
  # Inverting the CONVERSIONS hash would result in collapsed values.

  CONVERSIONS = {
    "Law"        => "Law, Government, or Public Service",
    "Science"    => "Manufacturing, Science, Technology, Engineering and/or Math",
    "Technology" => "Manufacturing, Science, Technology, Engineering and/or Math",
    "Human Services" => "Law, Government, or Public Service",
    "Art or Graphic Design"         => "Visual or Performing Arts",
    "Engineering and/or Math"       => "Manufacturing, Science, Technology, Engineering and/or Math",
    "Theatre or Performing Arts"    => "Visual or Performing Arts",
    "Business or Entrepreneurship"  => "Business",
    "Veterinary or Marine Science"  => "Marine Industries",
    "Government, or Public Service" => "Law, Government, or Public Service"
  }

end
