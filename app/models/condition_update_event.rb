#
# Condition update event. This is event type is required for
# all implementations
#
class ConditionUpdateEvent < AssetEvent
      
  # Callbacks
  after_initialize :set_defaults
      
  # Associations
  
  # Condition of the asset
  belongs_to  :condition_type
      
  validates :condition_type_id, :presence => true
  validates :assessed_rating,   :numericality => {:greater_than_or_equal_to => 0, :less_than_or_equal_to => 5}, :allow_nil => :true
  validates :current_mileage,   :numericality => {:greater_than_or_equal_to => 0, :less_than_or_equal_to => 1000000,  :only_integer => :true}, :allow_nil => :true
  
  before_validation do
    self.assessed_rating ||= ConditionType.find(condition_type_id).rating unless condition_type_id.blank?
  end
    
  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_event_type_id => AssetEventType.find_by_class_name(self.name).id).order(:event_date) }
    
  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :condition_type_id,
    :assessed_rating,
    :current_mileage
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

  # Override numeric setters to remove any extraneous formats from the number strings eg $, etc.      
  def assessed_rating=(num)
    self[:assessed_rating] = sanitize_to_float(num)
  end      
  def current_mileage=(num)
    self[:current_mileage] = sanitize_to_int(num)
  end      

  # This must be overriden otherwise a stack error will occur  
  def get_update
    condition_type.name unless condition_type.nil?
  end
  
  protected

  # Set resonable defaults for a new condition update event
  def set_defaults
    super
    self.asset_event_type ||= AssetEventType.find_by_class_name(self.name)
  end    
  
end
