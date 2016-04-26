class Run < ActiveRecord::Base

  after_initialize :ensure_seed
  after_initialize :set_config

  extend Enumerize

  default_scope { order(:id) }

  has_many :placements, dependent: :destroy

  enumerize :status, in: [:fresh, :running, :failed, :succeeded],
    predicates: true, default: :fresh

  validates :seed, presence: true, numericality: {
    greater_than_or_equal_to: 1000,
    less_than_or_equal_to:    9999
  }

  # Consider yielding the object
  def applicant_ids
    Applicant.random.where.not(grid_id: nil).pluck(:id)
  end

  def actionable_placement_ids(limit: nil)
    placements.where(market: :automatic).
      where(status: :pending).
      where(position: nil).
      order(:index).
      limit(limit).
      pluck(:id)
  end

  def exportable_placements
    placements.includes(:applicant, :position).
      where(status: [:placed, :synced]). # Nothing still pending.
      order(:index) # Pleasantly redundant with Placement.default_scope
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

end
