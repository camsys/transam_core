#
# Location update event. This is event type is required for
# all implementations
#
class LocationUpdateEvent < AssetEvent

  # Callbacks
  after_initialize :set_defaults
  after_save       :update_asset

  # Associations

  # Each event has a location_id and a location description
  belongs_to  :parent,  :class_name => Rails.application.config.asset_base_class_name, :foreign_key => :parent_id

  validates   :parent, :presence => true

  attr_accessor :parent_name

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_event_type_id => AssetEventType.find_by_class_name(self.name).id).order(:event_date) }

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :parent_key,
    :parent_name
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
    "Located at #{parent.asset_subtype} #{parent}" unless parent.nil?
  end
 
  def parent_key=(object_key)
    self.parent = TransamAsset.find_by_object_key(object_key)
  end
  def parent_key
    parent.object_key if parent
  end

  def parent_name
    parent.to_s
  end

  protected

  # Forces an update of an assets location. This performs an update on the record.
  def update_asset

    Rails.logger.debug "Updating the recorded location for asset = #{transam_asset.object_key}"

    if transam_asset.location_updates.empty?
      transam_asset.location_id = nil
    else
      event = transam_asset.location_updates.last
      transam_asset.location_id = event.parent_id
    end
    # save changes to this asset
    transam_asset.save
  end

  # Set resonable defaults for a new condition update event
  def set_defaults
    super
    self.parent ||= transam_asset.try(:parent)
    self.asset_event_type ||= AssetEventType.find_by_class_name(self.name)
  end

end
