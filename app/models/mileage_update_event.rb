#
# Mileage update event. 
#
class MileageUpdateEvent < AssetEvent
      
  # Callbacks
  after_initialize :set_defaults
      
  # Associations
  validates :current_mileage, :presence => :true, :numericality => {:greater_than_or_equal_to => 0, :less_than_or_equal_to => 1000000,  :only_integer => :true}
  validate  :monotonically_increasing_mileage
  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_event_type_id => AssetEventType.find_by_class_name(self.name).id).order(:event_date, :created_at) }
    
  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
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

  def current_mileage=(num)
    unless num.blank?
      self[:current_mileage] = sanitize_to_int(num)
    end
  end      

  # This must be overriden otherwise a stack error will occur  
  def get_update
    "Mileage recorded as #{helper.number_with_delimiter(current_mileage)}." unless current_mileage.nil?
  end
  
  protected

  # Set resonable defaults for a new condition update event
  def set_defaults
    super
    self.asset_event_type ||= AssetEventType.find_by_class_name(self.name)
  end    

  # Ensure that the mileage is between the previous (if any) and the following (if any)
  # Mileage must increase OR STAY THE SAME over time
  def monotonically_increasing_mileage
    previous_mileage_update = self.previous_event_of_type
    next_mileage_update = self.next_event_of_type
    if previous_mileage_update
      errors.add(:current_mileage, "can't be less than last update (#{previous_mileage_update.current_mileage})") if current_mileage < previous_mileage_update.current_mileage
    end
    if next_mileage_update
      errors.add(:current_mileage, "can't be more than next update (#{next_mileage_update.current_mileage})") if current_mileage > next_mileage_update.current_mileage
    end
  end
  
end
