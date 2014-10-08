#
# Schedule Disposition update event. This is event type is required for
# all implementations
#
class ScheduleDispositionUpdateEvent < AssetEvent
      
  # Callbacks
  after_initialize :set_defaults
      
  # Associations
        
  validates :disposition_year, :presence => true
      
  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_event_type_id => AssetEventType.find_by_class_name(self.name).id).order(:event_date, :created_at) }
    
  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :disposition_year
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
    "Scheduled for disposition in #{fiscal_year(disposition_year)}"
  end
  
  protected

  # Set resonable defaults for a new schedule disposition update event
  def set_defaults
    super
    self.disposition_year ||= current_planning_year_year
  end    
end
