require 'test_helper'

class InterestSplitterTest < Minitest::Test

  def splitter
    InterestSplitter
  end

  def test_splits
    assert_equal sample_list, splitter.split(sample_string)
    assert_equal list, splitter.split(comprehensive_string)
    assert_equal list, splitter.split(shuffled_string)
  end

  private

  def sample_string
    'Admin or Office Assistant, Business or Entrepreneurship, Community Organizing, Digital Media, Communications or Film, Education or Tutoring, Engineering and/or Math, Government, or Public Service, Health Care, Hospitality & Tourism, Information Technology, Law, Peer Leadership, Science, Sports, Fitness and/or Recreation, Technology, Veterinary or Marine Science, Visual or Performing Arts'
  end

  def sample_list
    ['Admin or Office Assistant', 'Business or Entrepreneurship',
     'Community Organizing', 'Digital Media, Communications or Film',
     'Education or Tutoring', 'Engineering and/or Math',
     'Government, or Public Service', 'Health Care', 'Hospitality & Tourism',
     'Information Technology', 'Law', 'Peer Leadership', 'Science',
     'Sports, Fitness and/or Recreation', 'Technology',
     'Veterinary or Marine Science', 'Visual or Performing Arts']
  end

  def comprehensive_string
    @_comprehensive ||= list.join(', ')
  end

  def shuffled_string
    @_shuffled ||= list.shuffle.join(', ')
  end

  def list
    ["Admin or Office Assistant", "Art or Graphic Design", "Business or Entrepreneurship",
    "Child Care or Teacher's Assistant", "Community Organizing",
    "Construction or Building Trades", "Education or Tutoring",
    "Engineering and/or Math",
    "Environment, Natural Resources, and/or Agriculture",
    "Government, or Public Service", "Health Care",
    "Hospitality & Tourism", "Hospitality &amp; Tourism", "Human Services", "Information Technology", "Law",
    "Maintenance/Landscaping", "Other", "Peer Leadership", "Science",
    "Sports, Fitness and/or Recreation", "Technology", "Theatre or Performing Arts", "Transportation",
    "Veterinary or Marine Science", "Visual or Performing Arts",]
  end

end
