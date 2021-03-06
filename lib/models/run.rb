class Run < ActiveRecord::Base

  after_initialize :ensure_seed
  after_initialize :set_config
  after_create     :prepopulate_positions
  before_destroy   :destroy_placements

  extend Enumerize

  default_scope { order(:id) }

  has_many :placements, dependent: :destroy

  enumerize :status, in: [:fresh, :running, :failed, :succeeded],
    predicates: true, default: :fresh

  validates :seed, presence: true, numericality: {
    greater_than_or_equal_to: 1000,
    less_than_or_equal_to:    9999
  }

  def applicants
    Applicant.eligible_for_lottery
  end

  def placeable_placements(limit: nil)
    placements.placeable.limit(limit)
  end

  def refreshable_declined_placements
    placements.declined_refreshable(run: self)
  end

  def exportable_placements
    placements.exportable
  end

  def unavailable_placements
    placements.unavailable
  end

  def add_to_available(position)
    self.available_positions_will_change!
    self.available_positions << position.id
    self.available_positions.uniq!
    self.save!
  end

  def remove_from_available(position)
    self.available_positions_will_change!
    self.available_positions.delete position.id
    self.save!
  end

  def reload_config!
    update_attribute :config, config_yaml
    $logger.info config
    return true
  end

  def placement_rate
    num = placements.where(market: :automatic).where.not(status: :pending).count
    den = placements.where(market: :automatic).count
    app_placement = (num / den.to_f) * 100
    pos_placement = (num / Position.pluck(:automatic).reduce(:+).to_f) * 100
    { applicants: app_placement, jobs: pos_placement }
  end

  def config
    read_attribute(:config).with_indifferent_access
  end

  def sql_seed
    seed.to_i / 10_000.to_f
  end

  def running!
    self.update_attribute(:status, :running)
  end

  def failed!
    self.update_attribute(:status, :failed)
  end

  def succeeded!
    self.update_attribute(:status, :succeeded)
  end

  def successful_placements
    placements.where.not(position: nil)
  end

  def failed_placements
    placements.where(position: nil)
  end

  private

  def set_seed
    ActiveRecord::Base.connection.execute("SELECT setseed(#{sql_seed})")
  end

  def set_config
    self.config = config_yaml if self.new_record?
  end

  def config_yaml
    YAML.load_file('./config/lottery.yml').with_indifferent_access
  end

  def ensure_seed
    self.seed ||= random_seed if self.new_record?
  end

  def random_seed
    rand(1000..9999)
  end

  def destroy_placements
    # Run.destroy_all hangs while destroying placements, maybe because we run
    #   out of RAM. This does each object at a time, which takes longer but
    #   doesn't seem to error the same way.
    placements.each(&:destroy!)
  end

  def prepopulate_positions
    update_attribute :available_positions, Position.where('automatic > ?', 0).pluck(:id)
  end

end
