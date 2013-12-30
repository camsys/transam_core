#
# Disposition update event. This is event type is required for
# all implementations
#
class DispositionUpdateEvent < AssetEvent
      
  # Callbacks
  after_initialize :set_defaults
      
  # Associations
  
  # Disposition of the asset
  belongs_to  :disposition_type
      
  # general accessors
  #attr_accessible :disposition_type_id
  
  validates :disposition_type_id, :presence => true
    
  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :disposition_type_id
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
    disposition_type.name unless disposition_type.nil?
  end
  
  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new condition update event
  def set_defaults
    self.asset_event_type ||= AssetEventType.find_by_class_name(self.name)
    super
  end    
  
end
