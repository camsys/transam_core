#
# Schedule Replacement update event. This is event type is required for
# all implementations
#
class ReplacementStatusUpdateEvent < AssetEvent
      
  # Callbacks
  after_initialize :set_defaults

  # Associations
  belongs_to  :replacement_status_type

  validates :replacement_status_type,  :presence => true
      
  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_event_type_id => AssetEventType.find_by_class_name(self.name).id).order(:event_date, :created_at) }
    
  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :replacement_year,
    :replacement_status_type_id
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
    "Replacement status: #{replacement_status_type}."
  end
  
  protected

  # Set resonable defaults for a new condition update event
  def set_defaults
    super
    self.replacement_status_type ||= ReplacementStatusType.find_by(:name => "By Policy")
  end    
  
end
