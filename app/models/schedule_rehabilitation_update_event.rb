#
# Schedule Rehabilitation update event. This is event type is required for
# all implementations
#
class ScheduleRehabilitationUpdateEvent < AssetEvent
      
  # Callbacks
  after_initialize :set_defaults
              
  validates :rebuild_year, :presence => true, :numericality => { :only_integer => true,  :greater_than_or_equal_to => Date.today.year - 10 }
      
  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_event_type_id => AssetEventType.find_by_class_name(self.name).id).order(:event_date, :created_at) }
    
  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :rebuild_year
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
    "Scheduled for rehabilitation in #{fiscal_year(rebuild_year)}."
  end
  
  protected

  # Set resonable defaults for a new condition update event
  def set_defaults
    super
    self.rebuild_year ||= current_planning_year_year
    self.asset_event_type ||= AssetEventType.find_by_class_name(self.name)
  end    

  
end
