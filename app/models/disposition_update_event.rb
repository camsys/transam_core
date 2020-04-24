# Disposition update event. This is event type is required for
# all implementations
#
class DispositionUpdateEvent < AssetEvent

  # Callbacks
  after_initialize :set_defaults
  after_save       :update_asset

  # Associations

  # Disposition of the asset
  belongs_to  :disposition_type

  validates :disposition_type,     :presence => true

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_event_type_id => AssetEventType.find_by_class_name(self.name).id).order(:event_date, :created_at) }

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :disposition_type_id
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
    "#{disposition_type} on #{event_date}"
  end

  ######## API Serializer ##############
  def api_json(options={})
    super.merge({
      disposition_type: disposition_type.api_json(options),
      sales_proceeds: sales_proceeds,
      mileage_at_disposition: mileage_at_disposition
    })
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
    self.disposition_type ||= transam_asset.disposition_updates.last.try(:disposition_type)
    self.asset_event_type ||= AssetEventType.find_by_class_name(self.name)
  end

  def update_asset
    AssetDispositionUpdateJob.new(transam_asset.object_key).perform
  end

end
