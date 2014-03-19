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

  # assessed condition rating
  #attr_accessible :assessed_rating
      
  validates                 :condition_type_id, :presence => true
  validates_numericality_of :assessed_rating, :greater_than_or_equal_to => 0,   :less_than_or_equal_to => 5, :allow_nil => :true
  validates_numericality_of :current_mileage, :greater_than_or_equal_to => 0,   :less_than_or_equal_to => 1000000,  :only_integer => :true,   :allow_nil => :true
  
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
