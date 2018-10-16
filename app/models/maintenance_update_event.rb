#
# Maintenance update event.

# This event is placed in core but Asset does not include it by default allowing
# concrete implementations use it as needed in individual asset classes
#
class MaintenanceUpdateEvent < AssetEvent

  # Callbacks
  after_initialize :set_defaults
  after_save       :update_asset

  # Associations

  # Condition of the asset
  belongs_to  :maintenance_type

  validates :maintenance_type, :presence => true
  validate  :monotonically_increasing_mileage

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------

  # set the default scope
  default_scope { where(:asset_event_type => asset_event_type).order(:event_date, :created_at) }

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :maintenance_type_id
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
    str = ""
    str += "#{maintenance_type}" unless maintenance_type.nil?
    str += "at #{current_mileage} miles" unless current_mileage.blank?
    str
  end

  protected

  # Set resonable defaults for a new condition update event
  # Should be overridden by any form fields during save
  def set_defaults
    super
    self.asset_event_type ||= AssetEventType.find_by_class_name(self.name)
  end

  def update_asset
    if current_mileage.present?
      typed_asset = TransamAsset.get_typed_asset(transam_asset)
      typed_asset.mileage_updates.create(event_date: self.event_date, current_mileage: self.current_mileage) if (typed_asset.respond_to? :mileage_updates)
    end
  end

  # Ensure that the mileage is between the previous (if any) and the following (if any)
  # Mileage must increase OR STAY THE SAME over time
  def monotonically_increasing_mileage
    if transam_asset
      previous_mileage_update = transam_asset.asset_events
                  .where.not(current_mileage: nil)
                  .where("event_date < ? OR (event_date = ? AND created_at < ?)", self.event_date, self.event_date, (self.new_record? ? Time.current : self.created_at) ) # Define a window that runs up to this event
                  .where('object_key != ?', self.object_key)
                  .order(:event_date, :created_at => :asc).last
      next_mileage_update = transam_asset.asset_events
                  .where.not(current_mileage: nil)
                  .where('event_date > ? OR (event_date = ? AND created_at > ?)', self.event_date, self.event_date, (self.new_record? ? Time.current : self.created_at )) # Define a window that backs up to this event
                  .where('object_key != ?', self.object_key)
                  .order(:event_date, :created_at => :desc).first

      if previous_mileage_update
        errors.add(:current_mileage, "can't be less than last update (#{previous_mileage_update.current_mileage})") if current_mileage < previous_mileage_update.current_mileage
      end
      if next_mileage_update
        errors.add(:current_mileage, "can't be more than next update (#{next_mileage_update.current_mileage})") if current_mileage > next_mileage_update.current_mileage
      end
    end
  end

end
