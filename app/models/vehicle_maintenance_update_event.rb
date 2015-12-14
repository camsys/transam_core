#
# Vehicle Maintenance update event.

# This event records maintenance and current mileage for a vehicle asset
#
class VehicleMaintenanceUpdateEvent < AssetEvent

  # Callbacks
  after_initialize :set_defaults

  # Associations

  # Condition of the asset
  belongs_to  :maintenance_type

  validates :maintenance_type, :presence => true
  validates :current_mileage, :presence => :true, :numericality => {:greater_than_or_equal_to => 0, :only_integer => :true}

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------

  # set the default scope
  default_scope { where(:asset_event_type => asset_event_type).order(:event_date, :created_at) }

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :maintenance_type_id,
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

  # This must be overriden otherwise a stack error will occur
  def get_update
    "#{maintenance_type} at #{current_mileage}  miles." unless maintenance_type.nil?
  end

  def current_mileage=(num)
    unless num.blank?
      self[:current_mileage] = sanitize_to_int(num)
    end
  end

  protected

  # Set resonable defaults for a new condition update event
  # Should be overridden by any form fields during save
  def set_defaults
    super
    self.asset_event_type ||= AssetEventType.find_by_class_name(self.name)
    self.current_mileage  ||= 0
  end

end
