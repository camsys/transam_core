#
# Rehabilitation update event. This is event type is required for
# all implementations
#
class RehabilitationUpdateEvent < AssetEvent

  # Callbacks
  after_initialize :set_defaults

  # Associations
  has_many :asset_event_asset_subsystems, :foreign_key => "asset_event_id", :dependent => :destroy
  accepts_nested_attributes_for :asset_event_asset_subsystems, :allow_destroy => true, :reject_if   => lambda{ |attrs| attrs[:parts_cost].blank? and attrs[:labor_cost].blank? }

  has_many :asset_subsystems, :through => :asset_event_asset_subsystems

  validates :extended_useful_life_months, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}, allow_nil: true

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_event_type_id => AssetEventType.find_by_class_name(self.name).id).order(:event_date, :created_at) }

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :total_cost,
    :extended_useful_life_months,
    :asset_event_asset_subsystems_attributes => [AssetEventAssetSubsystem.allowable_params]
  ]

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
  end

  #returns the asset event type for this type of event
  def self.asset_event_type
    AssetEventType.find_by_class_name(self.name)
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  def get_update
    "Rehabilitation: $#{cost}: #{asset_subsystems.join(",")}"
  end

  def cost
    if total_cost
      total_cost
    else
      parts_cost + labor_cost # sum up the costs from subsystems
    end
  end

  # Cost for each piece is the sum of what's spent on subsystems
  def parts_cost
    asset_event_asset_subsystems.map(&:parts_cost).compact.reduce(0, :+)
  end
  def labor_cost
    asset_event_asset_subsystems.map(&:labor_cost).compact.reduce(0, :+)
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new rehab update event
  def set_defaults
    super
    self.extended_useful_life_months ||= 0
  end

end
