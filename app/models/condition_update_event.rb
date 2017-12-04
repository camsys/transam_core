#
# Condition update event. This is event type is required for
# all implementations
#
class ConditionUpdateEvent < AssetEvent

  # Callbacks
  after_initialize :set_defaults

  # Associations
  has_many :condition_type_percents, :foreign_key => "asset_event_id", :dependent => :destroy
  accepts_nested_attributes_for :condition_type_percents, :allow_destroy => true


  # Condition of the asset
  belongs_to  :condition_type

  validates :condition_type, :presence => true
  validates :assessed_rating,
      :presence     => true,
      :numericality => {
      :greater_than_or_equal_to => ConditionType.minimum(:rating),
      :less_than_or_equal_to    => ConditionType.maximum(:rating)
      },
      :allow_nil    => true
  # validates :comments, :length => {:maximum => ???} # There is no limit in the Database/Schema

  before_validation do
    self.condition_type ||= ConditionType.from_rating(assessed_rating) unless assessed_rating.blank?
  end

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_event_type => asset_event_type).order(:event_date, :created_at) }

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :condition_type_id,
    :assessed_rating,
    :condition_type_percents_attributes => [ConditionTypePercent.allowable_params]
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

  # usually no conditions on can create but can be overridden by specific asset events
  def can_update?
    asset_event_type.active && asset.dependents.count == 0
  end

  # Override numeric setters to remove any extraneous formats from the number strings eg $, etc.
  def assessed_rating=(num)
    self[:assessed_rating] = sanitize_to_float(num) unless num.blank?
  end

  # This must be overriden otherwise a stack error will occur
  def get_update
    if condition_type.nil?
      "Condition recorded as #{sprintf("%#.1f", assessed_rating)}"
    else
      "Condition recorded as #{sprintf("%#.1f", assessed_rating)} (#{condition_type})"
    end
  end

  protected

  # Set resonable defaults for a new condition update event
  # Should be overridden by any form fields during save
  def set_defaults
    super
    self.assessed_rating ||= (asset.reported_condition_rating || ConditionType.maximum(:rating))
    self.asset_event_type ||= AssetEventType.find_by_class_name(self.name)
  end

end
