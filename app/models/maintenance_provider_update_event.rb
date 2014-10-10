#
# Maintenance Provider update event. This event records the current operations for a BPT asset
#
class MaintenanceProviderUpdateEvent < AssetEvent
      
  # Callbacks
  after_initialize :set_defaults
      
  # Associations  
  belongs_to  :maintenance_provider_type
      
  # Validations
  validates   :maintenance_provider_type_id,    :presence => true
      
  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_event_type_id => AssetEventType.find_by_class_name(self.name).id).order(:event_date) }
    
  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :maintenance_provider_type_id
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
    
  # This must be overriden otherwise a stack error will occur  
  def get_update
    maintenance_provider_type unless maintenance_provider_type.nil?
  end
  
  protected

  # Set resonable defaults for a new condition update event
  def set_defaults
    super
    self.asset_event_type ||= AssetEventType.find_by_class_name(self.name)
    self.maintenance_provider_type ||= asset.maintenance_provider_type
  end    
  
end
