#
# Abstract class for events. All implementation specific events are derived from
# this
#
class AssetEvent < ActiveRecord::Base
      
  # Include the object key mixin
  include TransamObjectKey
  # Include the numeric sanitizers mixin
  include TransamNumericSanitizers
  # Include the fiscal year mixin
  include FiscalYear

  #------------------------------------------------------------------------------
  # Overrides
  #------------------------------------------------------------------------------
  
      
  # Callbacks
  after_initialize :set_defaults

  # Associations
  
  # Every event belongs to an asset
  belongs_to  :asset
  # Every event is of a type
  belongs_to  :asset_event_type
  # Assets can be associated with Uploads
  belongs_to  :upload
  
  validates :asset_id,            :presence => true
  validates :asset_event_type_id, :presence => true
  validates :event_date,          :presence => true
    
  # default scope
  default_scope { order("event_date") }
  # named scopes

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :asset_id,
    :asset_event_type_id, 
    :asset_type_id, 
    :event_date, 
    :comments
  ]
  
  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------
    
  def self.allowable_params
    FORM_PARAMS
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

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  # returns true if the organization instance is strongly typed, i.e., a concrete class
  # false otherwise.
  # true
  def is_typed?
    self.class.to_s == asset_event_type.class_name
  end
      
  # Return the update by coercing as a typed class and returning the appropriate
  # update from it
  def get_update
    # get a typed version of the asset event and return its value
    evt = is_typed? ? self : AssetEvent.as_typed_event(self)
    return evt.get_update unless evt.nil?    
  end  


  #------------------------------------------------------------------------------
  #
  # Traversal Methods
  #
  #------------------------------------------------------------------------------

  # Get the chronologically next event on this event's asset of the same type as the caller
  # If one already exists for the same event_date, return the last created
  # If none exists, returns nil
  def next_event_of_type
    event = asset.asset_events
      .where('asset_event_type_id = ?', self.asset_event_type_id)
      .where('event_date > ? OR (event_date = ? AND created_at > ?)', self.event_date, self.event_date, (self.new_record? ? Time.current : self.created_at )) # Define a window that backs up to this event
      .order(:event_date, :created_at => :desc).first

    # Return Strongly Typed Asset
    AssetEvent.as_typed_event(event)
  end

  # Get the chronologically preceding event on this event's asset of the same type as the caller
  # If one already exists for the same event_date, return the last created
  # If none exists, returns nil
  def previous_event_of_type
    event = asset.asset_events
      .where("asset_event_type_id = ?", self.asset_event_type_id) # get events of same type
      .where("event_date < ? OR (event_date = ? AND created_at < ?)", self.event_date, self.event_date, (self.new_record? ? Time.current : self.created_at) ) # Define a window that runs up to this event
      .order(:event_date, :created_at => :asc).last

    # Return Strongly Typed Asset
    AssetEvent.as_typed_event(event)
  end
  
  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new asset event
  def set_defaults
    self.event_date ||= Date.today
  end
end
