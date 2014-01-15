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
      
  validates :condition_type_id, :presence => true
  
  before_validation do
    self.assessed_rating ||= ConditionType.find(condition_type_id).rating
  end
    
  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_event_type_id => AssetEventType.find_by_class_name(self.name).id).order(:event_date) }
    
  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :condition_type_id,
    :assessed_rating
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
