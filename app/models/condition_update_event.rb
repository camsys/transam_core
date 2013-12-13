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
  attr_accessible :assessed_rating

  # time (day/night) that the inspection was performed
  belongs_to  :time_of_day_type

  # retro reflectivity measure
  attr_accessible :reteroreflectivity
      
  # general accessors
  attr_accessible :condition_type_id, :time_of_day_type_id  
  
  validates :condition_type_id, :presence => true
  validates :time_of_day_type_id, :presence => true
  validates :reteroreflectivity, :presence => true
  before_validation do
    self.assessed_rating ||= ConditionType.find(condition_type_id).rating
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
    self.reteroreflectivity ||= 0.0
    self.asset_event_type ||= AssetEventType.find_by_class_name(self.name)
  end    
  
end
