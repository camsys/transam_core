#
# Puchase event. This is event type is required for
# all implementations and records the date that an asset
# was purchased
#
class PurchaseEvent < AssetEvent
      
  # Callbacks
  after_initialize :set_defaults
      
  # Associations
  belongs_to    :seller,  :class_name => "Organization", :foreign_key => :seller_id
  
  validates_numericality_of :purchase_cost,         :greater_than_or_equal_to => 0,   :only_integer => :true
  validates_numericality_of :expected_useful_life,  :greater_than_or_equal_to => 0,   :only_integer => :true, :allow_nil => :true
  validates_numericality_of :expected_useful_miles, :greater_than_or_equal_to => 0,   :only_integer => :true, :allow_nil => :true

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_event_type_id => AssetEventType.find_by_class_name(self.name).id).order(:event_date) }
    
  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :purchase_cost,
    :purchased_new,
    :seller_id,
    :expected_useful_life,
    :expected_useful_miles,
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

  # This must be overriden otherwise a stack error will occur  
  def get_update
    purchase_cost
  end
  
  protected

  # Set resonable defaults for a new condition update event
  def set_defaults
    super
    self.asset_event_type ||= AssetEventType.find_by_class_name(self.name)
  end    
  
end
