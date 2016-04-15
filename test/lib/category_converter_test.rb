require 'test_helper'

class CategoryConverterTest < Minitest::Test

  def splitter
    CategoryConverter
  end

  def test_convert
    CATEGORIES_WITH_CONVERSIONS.each_pair do |from, expected|
      assert_equal expected, splitter.convert(from)
    end
  end

  private

  CATEGORIES_WITH_CONVERSIONS = {
    "Admin or Office Assistant" => "Admin or Office Assistant",
    "Business or Entrepreneurship" => "Business",
    "Child Care or Teacher's Assistant" => "Child Care or Teacher's Assistant",
    "Community Organizing" => "Community Organizing",
    "Construction or Building Trades" => "Construction or Building Trades",
    "Education or Tutoring" => "Education or Tutoring",
    "Engineering and/or Math" => "Manufacturing, Science, Technology, Engineering and/or Math",
    "Environment, Natural Resources, and/or Agriculture" => "Environment, Natural Resources, and/or Agriculture",
    "Government, or Public Service" => "Law, Government, or Public Service",
    "Health Care" => "Health Care",
    "Hospitality &amp; Tourism" => "Hospitality &amp; Tourism",
    "Information Technology" => "Information Technology",
    "Law" => "Law, Government, or Public Service",
    "Maintenance/Landscaping" => "Maintenance/Landscaping",
    "Other" => "Other",
    "Peer Leadership" => "Peer Leadership",
    "Science" => "Manufacturing, Science, Technology, Engineering and/or Math",
    "Sports, Fitness and/or Recreation" => "Sports, Fitness and/or Recreation",
    "Technology" => "Manufacturing, Science, Technology, Engineering and/or Math",
    "Transportation" => "Transportation",
    "Veterinary or Marine Science" => "Marine Industries",
    "Visual or Performing Arts" => "Visual or Performing Arts",
    "Theatre or Performing Arts" => "Visual or Performing Arts",
    "Human Services" => "Law, Government, or Public Service",
    "Art or Graphic Design" => "Visual or Performing Arts"
  }

end
