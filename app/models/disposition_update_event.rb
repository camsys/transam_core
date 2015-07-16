#
# Disposition update event. This is event type is required for
# all implementations
#
class DispositionUpdateEvent < AssetEvent

  # Callbacks
  after_initialize :set_defaults

  # Associations

  # Alias current_mileage to mileage_disposition so we can re-use the existing attribute
  alias_attribute :mileage_at_disposition,  :current_mileage
  # Alias age_at_disposition to replacement_year so we can re-use the existing attribute
  alias_attribute :age_at_disposition,      :replacement_year

  # Disposition of the asset
  belongs_to  :disposition_type

  validates :disposition_type,      :presence => true
  validates :sales_proceeds,        :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  validates :mileage_at_disposition,:presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}, if: Proc.new { |event| event.asset.asset_type == "Vehicle" || event.asset.asset_type.class_name == "SupportVehicle" }
  validates :age_at_disposition,    :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  #validates :new_owner_name,      :presence => true
  #validates :address1,            :presence => true
  #validates :city,                :presence => true
  #validates :state,               :presence => true
  #validates :zip,                 :presence => true
  #validates_format_of :zip,       :with => /\A\d{5}([\-]?\d{4})?\z/

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_event_type_id => AssetEventType.find_by_class_name(self.name).id).order(:event_date, :created_at) }

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :disposition_type_id,
    :sales_proceeds,
    :age_at_disposition,
    :mileage_at_disposition,
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

  def age_at_disposition=(num)
    self[:replacement_year] = sanitize_to_int(num)
  end

  def mileage_at_disposition=(num)
    self[:current_mileage] = sanitize_to_int(num)
  end

  def get_update
    "#{disposition_type} on #{event_date}"
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
    self.disposition_type ||= asset.disposition_type
    self.asset_event_type ||= AssetEventType.find_by_class_name(self.name)
  end

end
