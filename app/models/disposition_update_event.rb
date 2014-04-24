#
# Disposition update event. This is event type is required for
# all implementations
#
class DispositionUpdateEvent < AssetEvent
      
  # Callbacks
  after_initialize :set_defaults
      
  # Associations
  
  # Disposition of the asset
  belongs_to  :disposition_type
        
  validates :disposition_type_id, :presence => true
  validates :sales_proceeds,      :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}, :allow_nil => true 
  validates :new_owner_name,      :presence => true
   
  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_event_type_id => AssetEventType.find_by_class_name(self.name).id).order(:event_date) }
    
  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :disposition_type_id,
    :sales_proceeds,
    :new_owner_name,
    :address1,
    :address2,
    :city,
    :state,
    :zip
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

  # Override setters to remove any extraneous formats from the number strings eg $, etc.      
  def sales_proceeds=(num)
    self[:sales_proceeds] = sanitize_to_int(num)
  end      
  
  
  def get_update
    disposition_type.name unless disposition_type.nil?
  end
  
  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new condition update event
  def set_defaults
    super
    self.asset_event_type ||= AssetEventType.find_by_class_name(self.name)
  end    
  
end
