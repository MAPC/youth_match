module Initializers

  def self.load
    Dir.glob('./config/initializers/*.rb').each { |file| require file }
    constants.each do |submodule|
      "Initializers::#{submodule}".constantize.send(:load)
    end
  end
end
