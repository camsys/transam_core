#
# Schedule Replacement update event. This is event type is required for
# all implementations
#
class ScheduleReplacementUpdateEvent < AssetEvent
      
  # Callbacks
  after_initialize :set_defaults
      
  # Associations
        
  validates :replacement_year,  :numericality => {:only_integer => :true,   :greater_than_or_equal_to => Date.today.year - 1}, :allow_nil => true
  validates :rebuild_year,      :numericality => {:only_integer => :true,   :greater_than_or_equal_to => Date.today.year - 1}, :allow_nil => true
      
  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_event_type_id => AssetEventType.find_by_class_name(self.name).id).order(:event_date) }
    
  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :replacement_year,
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
    elems = []
    if replacement_year
      elems << "Replace #{replacement_year}"
    end
    if rebuild_year
      elems << "Rebuild #{rebuild_year}"
    end
    elems.compact.join(', ')   
  end
  
  protected

  # Set resonable defaults for a new condition update event
  def set_defaults
    super
    self.replacement_year = Date.today.year
    self.asset_event_type ||= AssetEventType.find_by_class_name(self.name)
  end    
  
end
