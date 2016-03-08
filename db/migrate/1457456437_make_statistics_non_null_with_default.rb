require 'enumerize'
require './lib/models/run'
class MakeStatisticsNonNullWithDefault < ActiveRecord::Migration

  def up
    Run.find_each {|run| run.update_attribute(:statistics, {}) if run.statistics.nil?}
    change_column_null :runs, :statistics, false
    change_column_default :runs, :statistics, {}
  end

  def down
    change_column_null :runs, :statistics, true
    change_column_default :runs, :statistics, nil
  end

end
