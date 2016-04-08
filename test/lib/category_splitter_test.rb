require 'test_helper'

class CategorySplitterTest < Minitest::Test

  def splitter
    CategorySplitter
  end

  def test_split_properly
    CATEGORIES_WITH_SPLITS.each do |obj|
      actual = splitter.split obj[:text]
      expected = obj[:split]
      assert_equal expected, actual
    end
  end

  private

  CATEGORIES_WITH_SPLITS = [
    { text: "Admin or Office Assistant", split: ['Admin', 'Office Assistant'] },
    {
      text: "Business or Entrepreneurship",
      split: ['Business', 'Entrepreneurship']
    },
    {
      text: "Child Care or Teacher's Assistant",
      split: ['Child Care', "Teacher's Assistant"]
    },
    { text: "Community Organizing", split: ['Community Organizing'] },
    {
      text: "Construction or Building Trades",
      split: ['Construction', 'Building Trades']
    },
    {
      text: "Digital Media, Communications or Film",
      split: ['Digital Media', 'Communications', 'Film']
    },
    { text: "Education or Tutoring", split: ['Education', 'Tutoring'] },
    { text: "Engineering and/or Math", split: ['Engineering', 'Math'] },
    {
      text: "Environment, Natural Resources, and/or Agriculture",
      split: ['Environment', 'Natural Resources', 'Agriculture']
    },
    { text: "Government, or Public Service", split: ['Government', 'Public Service'] },
    { text: "Health Care", split: ['Health Care'] },
    { text: "Hospitality &amp; Tourism", split: ['Hospitality', 'Tourism'] },
    { text: "Information Technology", split: ['Information Technology'] },
    { text: "Law", split: ['Law'] },
    { text: "Maintenance/Landscaping", split: ['Maintenance', 'Landscaping'] },
    { text: "Other", split: ['Other'] },
    { text: "Peer Leadership", split: ['Peer Leadership'] },
    { text: "Science", split: ['Science'] },
    {
      text: "Sports, Fitness and/or Recreation",
      split: ['Sports', 'Fitness', 'Recreation']
    },
    { text: "Technology", split: ['Technology'] },
    { text: "Transportation", split: ['Transportation'] },
    {
      text: "Veterinary or Marine Science",
      split: ['Veterinary', 'Marine Science']
    },
    { text: "Visual or Performing Arts", split: ['Visual', 'Performing Arts'] },
    { text: "Business", split: ['Business'] },
    {
      text: "Media, Communications or Film",
      split: ['Media', 'Communications', 'Film']
    },
    {
      text: "Media, Communications, or Film",
      split: ['Media', 'Communications', 'Film']
    },
    {
      text: "Manufacturing, Science, Technology, Engineering and/or Math",
      split: ['Manufacturing', 'Science', 'Technology', 'Engineering', 'Math']
    },
    {
      text: "Law, Government, or Public Service",
      split: ['Law', 'Government', 'Public Service']
    },
    { text: "Marine Industries", split: ['Marine Industries'] }
  ]

end
