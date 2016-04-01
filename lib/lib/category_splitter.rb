module CategorySplitter

  def self.split(string)
    string.gsub(REGEX, ',').split(',').
      map(&:strip).
      reject(&:empty?)
  end

  REGEX = /\s?or\s|\s?and\s|,|\/|&amp;|\sand\/or\s/i

end
