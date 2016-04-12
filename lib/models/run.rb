class Run < ActiveRecord::Base

  after_initialize :set_seed
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

  def set_config
    if self.new_record?
      self.config = YAML.load_file('./config/lottery.yml').
        with_indifferent_access
    end
  end

  def set_seed
    self.seed ||= random_seed if self.new_record?
  end

  def random_seed
    rand(1000..9999)
  end

end
