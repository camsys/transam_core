#
# Service Status Update Event. This is event type is required for
# all implementations and represents envets that change the service
# status of an asset: START SERVICE, SUSPEND SERVICE etc.
#
#
class ServiceStatusUpdateEvent < AssetEvent

  # Callbacks
  after_initialize :set_defaults

  # Associations

  # Service Status of the asset
  belongs_to  :service_status_type


  validates :service_status_type_id, :presence => true

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_event_type_id => AssetEventType.find_by_class_name(self.name).id).order(:event_date, :created_at) }

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :service_status_type_id
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

  def get_update
    "Service status changed to #{service_status_type}" unless service_status_type.nil?
  end

  # Set resonable defaults for a new condition update event
  def set_defaults
    super
    self.service_status_type ||= transam_asset.service_status_updates.last.try(:service_status_type) if transam_asset
    self.asset_event_type ||= AssetEventType.find_by_class_name(self.name)
  end

  ######## API Serializer ##############
  def api_json(options={})
    super.merge({
      service_status_type: service_status_type.api_json
    })
  end

end
