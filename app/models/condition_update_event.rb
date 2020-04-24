#
# Condition update event. This is event type is required for
# all implementations
#
class ConditionUpdateEvent < AssetEvent

  # Callbacks
  after_initialize :set_defaults

  # check policy
  after_save :check_policy
  after_destroy :check_policy

  # Associations
  has_many :condition_type_percents, :foreign_key => "asset_event_id", :inverse_of  => :condition_update_event, :dependent => :destroy
  accepts_nested_attributes_for :condition_type_percents, :allow_destroy => true, :reject_if   => lambda{ |attrs| attrs[:condition_type].blank? }


  # Condition of the asset
  belongs_to  :condition_type

  validates :condition_type, :presence => true
  validates :assessed_rating,
      :presence     => true,
      :numericality => {
      :greater_than_or_equal_to => ConditionType.min_rating || 0,
      :less_than_or_equal_to    => ConditionType.max_rating || 5
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
    asset_event_type.active #&& transam_asset.dependents.count == 0 ## temporaritly disable since not putting condition rollup in UI yet
  end

  # Override numeric setters to remove any extraneous formats from the number strings eg $, etc.
  def assessed_rating=(num)
    self[:assessed_rating] = sanitize_to_float(num) unless num.blank?
  end

  # This must be overriden otherwise a stack error will occur
  def get_update
    if condition_type.nil?
      "Condition recorded as #{sprintf("%#.2f", assessed_rating)}"
    else
      "Condition recorded as #{sprintf("%#.2f", assessed_rating)} (#{condition_type})"
    end
  end

  ######## API Serializer ##############
  def api_json(options={})
    super.merge({
      assessed_rating: assessed_rating
    })
  end

  protected

  # Set resonable defaults for a new condition update event
  # Should be overridden by any form fields during save
  def set_defaults
    super
    self.assessed_rating ||= transam_asset ? (transam_asset.condition_updates.last.try(:reported_condition_rating)) : ConditionType.max_rating
    self.asset_event_type ||= AssetEventType.find_by_class_name(self.name)
  end


  def check_policy
    if base_transam_asset
      base_transam_asset.send(:check_policy_rule)
      base_transam_asset.send(:update_asset_state)
    end
  end
end
