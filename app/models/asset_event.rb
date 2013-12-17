#
# Abstract class for events. All implementation specific events are derived from
# this
#
class AssetEvent < ActiveRecord::Base
      
  # Callbacks
  after_initialize :set_defaults
      
  # Associations
  
  # Every event belongs to an asset
  belongs_to  :asset
  # Every event is of a type
  belongs_to  :asset_event_type
  # User who performed the inspection
  belongs_to  :inspector, :class_name => "User", :foreign_key => :inspector_id
  # Date on which the event was observed. This would be the day of inspection
  attr_accessible :event_date
  # Comments added by the inspector
  attr_accessible :comments
   
  # Other accessors    
  #attr_accessible :asset_id, :asset_event_type_id, :condition_type_id, :inspector_id  
  
  validates :asset_id, :presence => true
  validates :asset_event_type_id, :presence => true
  validates :event_date, :presence => true
  validates :inspector_id, :presence => true
    
  # default scope
  default_scope { order("event_date DESC") }
  # named scopes
  
  
  # Factory method to return a strongly typed subclass of a new asset event
  # based on the asset event type
  def self.get_new_typed_event(asset_event_type)
    
    class_name = asset_event_type.class_name
    asset_event = class_name.constantize.new
    asset_event.asset_event_type = asset_event_type
    return asset_event

  end
  # Returns a typed version of itself. Every asset has a type and this will
  # return a specific asset type based on the AssetType attribute
  def self.as_typed_event(asset_event)
    if asset_event
      class_name = asset_event.asset_event_type.class_name
      klass = Object.const_get class_name
      o = klass.find(asset_event.id)
      return o
    end
  end
      
  # Return the update by coercing as a typed class and returning the appropriate
  # update from it
  def get_update
    evt = AssetEvent.as_typed_event(self)
    evt.get_update
  end
  
protected

  # Set resonable defaults for a new asset event
  def set_defaults
    self.event_date ||= Date.today
  end    
  
end
