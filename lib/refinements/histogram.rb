require 'rounding'

module Histogram
  refine Array do

    def to_histogram(start: 0, interval: 1)
      compact. # remove nils
      inject(Hash.new(0)) { |h, x|
        h[x.floor_to(start + interval)] += 1 ; h
      }
    end

  end
end
