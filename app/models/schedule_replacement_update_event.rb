#
# Schedule Replacement update event. This is event type is required for
# all implementations
#
class ScheduleReplacementUpdateEvent < AssetEvent
      
  # Callbacks
  after_initialize :set_defaults
      
  # Associations
  belongs_to  :replacement_reason_type      
        
  validates :replacement_year,  :numericality => {:only_integer => true,   :greater_than_or_equal_to => Date.today.year - 10}, :allow_nil => true
  validates :replacement_reason_type,  :presence => true
      
  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_event_type_id => AssetEventType.find_by_class_name(self.name).id).order(:event_date, :created_at) }
    
  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :replacement_reason_type_id,
    :replacement_year
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
    "Scheduled for replacement in #{fiscal_year(replacement_year)}. Reason: #{replacement_reason_type}."
  end
  
  protected

  # Set resonable defaults for a new condition update event
  def set_defaults
    super
    self.replacement_year ||= current_planning_year_year
    self.asset_event_type ||= AssetEventType.find_by_class_name(self.name)
    self.replacement_reason_type ||= ReplacementReasonType.find_by(:name => "Reached policy EUL")
  end    
  
end
