require 'rounding'
require './lib/refinements/histogram'

class StatsJob

  using Histogram
  # TODO
  #  - Each: Add travel times to an array
  #  - End: to_histogram

  def initialize(id)
    @run = Run.find(id)
  end

  def perform!
    @stats = OpenStruct.new(
      matched_nearby: 0, matched_with_interest: 0,
      placement_rate: 0, average_travel_time: 0, travel_times: [],
      geojson: {type: 'FeatureCollection', features: []}
    )

    @run.placements.includes(:applicant, :position).find_each do |placement|
      calculate_stats_for_placement(placement)
      build_geojson_for_placement(placement)
    end
    calculate_stats_for_run
    build_geojson_for_run
    @run.update_attribute(:statistics, @stats.to_h.to_json)
  end

  private

  def calculate_stats_for_placement(placement)
    applicant = placement.applicant
    position  = placement.position || NullPosition.new

    @stats.travel_times << placement.travel_time

    matched_nearby?(applicant, position)
    matched_with_interest?(applicant, position)
  end

  def calculate_stats_for_run
    @stats.placement_rate = placement_rate
    @stats.average_travel_time = average_travel_time
    histogram = @stats.travel_times.compact.map{|s| s / 60}.to_histogram(interval: 5)
    @stats.histogram = histogram.sort_by { |k, _v| k.to_i }
  end

  def build_geojson_for_placement(placement)
    @stats.geojson[:features] << applicant_point(placement.applicant, !placement.position.nil?)
    unless placement.position.nil?
      @stats.geojson[:features] << position_point(placement.position, true)
      @stats.geojson[:features] << placement_line(placement)
    end
  end

  def build_geojson_for_run
    # NO OP
  end

  def average_travel_time
    # Now that we have an array of travel times available, we should
    # edit this method to use that array.
    @run.placements.extend(DescriptiveStatistics).mean(&:travel_time)
  end

  def placement_rate
    @run.unplaced.count.to_f / @run.placements.count.to_f
  end

  def matched_nearby?(a, p)
    if a.prefers_nearby && p.within?(10.minutes, of: a)
      @stats.matched_nearby += 1
    end
  end

  def matched_with_interest?(a, p)
    if a.prefers_nearby && p.within?(10.minutes, of: a)
      @stats.matched_nearby += 1
    end
  end

  def placement_line(placement)
    applicant = placement.applicant
    position = placement.position

    travel = TravelScore.new(applicant: applicant, position: position).score
    interest = InterestScore.new(applicant: applicant, position: position).score
    total = travel + interest
    { type: "Feature",
      geometry: {
        type: "LineString",
        coordinates: [
          applicant.location.coordinates,
          position.location.coordinates
        ]
      },
      properties: {
        score: { total: total, travel: travel, interest: interest },
        mode: applicant.mode
      }
    }
  end

  def applicant_point(applicant, placed)
    {
      type: "Feature",
      geometry: {
        type: "Point",
        coordinates: applicant.location.coordinates
      },
      properties: {
        type: :applicant,
        interests: applicant.interests.join(', '),
        mode: applicant.mode,
        prefers_nearby: applicant.prefers_nearby?,
        placed: placed
      }
    }
  end

  def position_point(position, placed)
    {
      type: "Feature",
      geometry: {
        type: "Point",
        coordinates: position.location.coordinates
      },
      properties: {
        type: :position,
        category: position.category,
        placed: placed
      }
    }
  end

  class NullPosition
    def within?(*args) ; false ; end
    def within(*args) ; [] ; end
    def nil? ; true ; end
  end

end
