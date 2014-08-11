#------------------------------------------------------------------------------
#
# Asset
#
# Base class for all assets. This class represents a generic asset, subclasses represent concrete
# asset types.
#
#------------------------------------------------------------------------------
class Asset < ActiveRecord::Base

  # Include the unique key mixin
  include UniqueKey
  # Include the numeric sanitizers mixin
  include NumericSanitizers
  # Include the fiscal year mixin
  include FiscalYear

  #------------------------------------------------------------------------------
  # Overrides
  #------------------------------------------------------------------------------

  #require rails to use the asset key as the restful parameter. All URLS will be of the form
  # /inventory/{object_key}/...
  def to_param
    object_key
  end

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults

  # Always generate a unique asset key before saving to the database
  before_validation(:on => :create) do
    generate_unique_key(:object_key)
  end

  # Clean up any HABTM associations before the asset is destroyed
  before_destroy { districts.clear }

  #------------------------------------------------------------------------------
  # Associations common to all asset types
  #------------------------------------------------------------------------------

  # each asset belongs to a single organization
  belongs_to :organization

  # each asset has a single asset type
  belongs_to :asset_type

  # each asset has a single asset subtype
  belongs_to :asset_subtype

  # each asset has a single maintenance provider type
  belongs_to :maintenance_provider_type

  # Each asset has zero or more asset events. These are all events regardless of event type. Events are deleted when the asset is deleted
  has_many   :asset_events, :dependent => :destroy

  # each asset has zero or more condition updates
  has_many   :condition_updates, -> {where :asset_event_type_id => ConditionUpdateEvent.asset_event_type.id }, :class_name => "ConditionUpdateEvent"

  # each asset has zero or more maintenance provider updates. .
  has_many   :maintenance_provider_updates, -> {where :asset_event_type_id => MaintenanceProviderUpdateEvent.asset_event_type.id }, :class_name => "MaintenanceProviderUpdateEvent"

  # each asset has zero or more scheduled replacement updates
  has_many   :schedule_replacement_updates, -> {where :asset_event_type_id => ScheduleReplacementUpdateEvent.asset_event_type.id }, :class_name => "ScheduleReplacementUpdateEvent"

  # each asset has zero or more scheduled disposition updates
  has_many   :schedule_disposition_updates, -> {where :asset_event_type_id => ScheduleDispositionUpdateEvent.asset_event_type.id }, :class_name => "ScheduleDispositionUpdateEvent"

  # each asset has zero or more service status updates
  has_many   :service_status_updates, -> {where :asset_event_type_id => ServiceStatusUpdateEvent.asset_event_type.id }, :class_name => "ServiceStatusUpdateEvent"

  # each asset has zero or more disposition updates
  has_many   :disposition_updates, -> {where :asset_event_type_id => DispositionUpdateEvent.asset_event_type.id }, :class_name => "DispositionUpdateEvent"

  # Each asset has zero or more images. Images are deleted when the asset is deleted
  has_many    :images,      :as => :imagable,       :dependent => :destroy

  # Each asset has zero or more documents. Documents are deleted when the asset is deleted
  has_many    :documents,   :as => :documentable,   :dependent => :destroy

  # Each asset has zero or more comments. Comments are deleted when the asset is deleted
  has_many    :comments,    :as => :commentable, :dependent => :destroy

  # Each asset has zero or more notes. Notes are deleted when the asset is destroyed
  # Notes are deprecated and will be removed. Only use comments going forward
  has_many   :notes,        :dependent => :destroy

  # Each asset can have 0 or more dependents
  has_many    :dependents,  :class_name => 'Asset', :foreign_key => 'location_id', :dependent => :nullify
  
  # Each asset can be associated with 0 or more districts
  has_and_belongs_to_many :districts

  # Each asset was created and updated by a user
  belongs_to :creator, :class_name => "User", :foreign_key => "created_by_id"
  belongs_to :updator, :class_name => "User", :foreign_key => "updated_by_id"

  # Accessors for associations
  #attr_accessible :organization_id, :asset_type_id, :asset_subtype_id, :created_by_id, :updated_by_id

  # Validations on associations
  validates     :organization_id,     :presence => true
  validates     :asset_type_id,       :presence => true
  validates     :asset_subtype_id,    :presence => true
  validates     :created_by_id,       :presence => true
  validates     :manufacture_year,    :presence => true, :numericality => {:only_integer => :true, :greater_than_or_equal_to => 1900}
  validates     :expected_useful_life,:presence => true, :numericality => {:only_integer => :true, :greater_than => 0}

  #------------------------------------------------------------------------------
  # Attributes common to all asset types
  #------------------------------------------------------------------------------

  # A unique string key generated by TransAM to uniquely identify an asset externally
  #attr_accessible :object_key
  # An identiifier for the asset assigned by the user. Interoperable key used to tie the asset
  # to other business systems.
  #attr_accessible :asset_tag

  # Validations on core attributes
  validates       :object_key,        :presence => true, :uniqueness => true
  validates       :asset_tag,         :presence => true
  validates       :asset_tag,         :length   => {:maximum => 12}

  validates_uniqueness_of :asset_tag, scope: :organization

  #------------------------------------------------------------------------------
  # Attributes that are used to cache asset condition information.
  # This set of attributes are updated when the asset condirtion or disposition is
  # updated. Used for reporting only.
  #------------------------------------------------------------------------------

  # The last reported condition type for the asset
  belongs_to      :reported_condition_type,   :class_name => "ConditionType",   :foreign_key => :reported_condition_type_id

  # The last estimated condition type for the asset
  belongs_to      :estimated_condition_type,  :class_name => "ConditionType",   :foreign_key => :estimated_condition_type_id

  # The disposition type for the asset. Null if the asset is still operational
  belongs_to      :disposition_type

  # The last reported disposition type for the asset
  belongs_to      :service_status_type

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  default_scope { order("assets.asset_subtype_id") }

  #------------------------------------------------------------------------------
  # Lists. These lists are used by derived classes to make up lists of attributes
  # that can be used for operations like full text search etc. Each derived class
  # can add their own fields to the list
  #------------------------------------------------------------------------------

  # List of fields which can be searched using a simple text-based search
  SEARCHABLE_FIELDS = [
    'object_key',
    'asset_tag',
    'manufacture_year'
  ]

  # List of fields that should be nilled when a copy is made
  CLEANSABLE_FIELDS = [
    'object_key',
    'asset_tag',
    'policy_replacement_year',
    'estimated_replacement_year',
    'estimated_replacement_cost',
    'scheduled_replacement_year',
    'scheduled_rehabilitation_year',
    'scheduled_disposition_date',
    'in_backlog',
    'reported_condition_type_id',
    'reported_condition_rating',
    'reported_condition_date',
    'reported_mileage',
    'estimated_condition_type_id',
    'estimated_condition_rating',
    'service_status_type_id',
    'estimated_value',
    'disposition_type_id',
    'disposition_date'
 ]

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :object_key,
    :organization_id,
    :asset_type_id,
    :asset_subtype_id,
    :asset_tag,
    :manufacture_year,
    :policy_replacement_year,
    :estimated_replacement_year,
    :estimated_replacement_cost,
    :scheduled_replacement_year,
    :scheduled_rehabilitation_year,
    :scheduled_disposition_date,
    :estimated_value,
    :in_backlog,
    :reported_condition_type_id,
    :reported_condition_rating,
    :reported_condition_date,
    :estimated_condition_type_id,
    :estimated_condition_rating,
    :service_status_type_id,
    :service_status_date,
    :disposition_date,
    :disposition_type_id,
    :created_by_id,
    :updated_by_id
  ]

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
  end

  # Factory method to return a strongly typed subclass of a new asset
  # based on the asset subtype
  def self.new_asset(asset_subtype)

    asset_class_name = asset_subtype.asset_type.class_name
    asset = asset_class_name.constantize.new({:asset_subtype_id => asset_subtype.id})
    return asset

  end

  # Returns a typed version of an asset. Every asset has a type and this will
  # return a specific asset type based on the AssetType attribute
  def self.get_typed_asset(asset)
    if asset
      class_name = asset.asset_type.class_name
      klass = Object.const_get class_name
      o = klass.find(asset.id)
      return o
    end
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  # Returns true if the asset is of the specified class or has the specified class as
  # and ancestor (superclass).
  #
  # usage: a.type_of? type
  # where type can be one of:
  #    a symbol e.g :vehicle
  #    a class name eg Vehicle
  #    a string eg "vehicle"
  #
  def type_of?(type)
    begin
      self.class.ancestors.include?(type.to_s.classify.constantize)
    rescue
      false
    end
  end

  # Override numeric setters to remove any extraneous formats from the number strings eg $, etc.
  def manufacture_year=(num)
    self[:manufacture_year] = sanitize_to_int(num)
  end


  # Returns the initial cost of the asset. Derived classes should override this to
  # handle asset-class specific caluclations where needed
  def cost
    # get a typed version of the asset and return its value
    asset = is_typed? ? self : Asset.get_typed_asset(self)
    return asset.cost unless asset.nil?
  end

  # returns true if the asset instance is strongly typed, i.e., a concrete class
  # false otherwise.
  # true
  def is_typed?
    self.class.to_s == asset_type.class_name
  end

  # default name for an asset
  # sub classes should override this with a class-specific name
  def name
    return "#{asset_subtype.name} - #{asset_tag}"
  end

  # returns true if this instance can be geo_located. Always false for base class
  def geo_locatable?
    false
  end

  # return the number of years since the asset was manufactured. It can't be less than 0
  def age(on_date=Date.today)
    [on_date.year - manufacture_year, 0].max
  end

  # returns the list of events associated with this asset ordered by date, newest first
  def history
    AssetEvent.unscoped.where('asset_id = ?', id).order('event_date DESC')
  end

  # returns the the organizations's policy that governs the replacement of this asset. This needs to upcast
  # the organization type to a class that owns assets
  def policy
    org = Organization.get_typed_organization(organization)
    return org.get_policy
  end

  # initialize any policy-related items. THis method should be overridden for each sub class
  def initialize_policy_items(init_policy = nil)
    # Set the expected_useful_life
    if init_policy
      p = init_policy
    else
      p = policy
    end
    if p
      policy_item = p.get_policy_item(self)
      if policy_item 
        self.expected_useful_life = policy_item.max_service_life_years
      end
    end
  end

  # Record that the asset has been disposed. This updates the dispostion date and the disposition_type attributes
  def record_disposition
    Rails.logger.info "Recording final disposition for asset = #{object_key}"

    # Make sure we are working with a concrete asset class
    asset = is_typed? ? self : Asset.get_typed_asset(self)

    unless asset.new_record?
      unless asset.disposition_updates.empty?
        event = asset.disposition_updates.last
        asset.disposition_date = event.event_date
        asset.disposition_type = event.disposition_type
        asset.save
      end
    end
  end

  # Forces an update of an assets service status. This performs an update on the record
  def update_service_status
    Rails.logger.info "Updating service status for asset = #{object_key}"

    # Make sure we are working with a concrete asset class
    asset = is_typed? ? self : Asset.get_typed_asset(self)

    # can't do this if it is a new record as none of the IDs would be set
    unless asset.new_record?
      unless asset.service_status_updates.empty?
        event = asset.service_status_updates.last
        asset.service_status_date = event.event_date
        asset.service_status_type = event.service_status_type
        asset.save
      end
    end
  end

  # Forces an update of an assets estimated value. This performs an update on the record
  def update_estimated_value(policy = nil)

    # can't do this if it is a new record as none of the IDs would be set
    unless new_record?
      update_asset_value(policy)
    end
  end

  # Forces an update of an assets reported condition. This performs an update on the record. 
  def update_condition

    Rails.logger.info "Updating condition for asset = #{object_key}"

    # can't do this if it is a new record as none of the IDs would be set
    unless new_record?
      unless condition_updates.empty?
        event = condition_updates.last
        self.reported_condition_date = event.event_date
        self.reported_condition_rating = event.assessed_rating
        self.reported_condition_type = event.condition_type
        save
      end
    end

  end

  # Forces an update of an assets maintenance provider. This performs an update on the record.
  def update_maintenance_provider

    Rails.logger.info "Updating the recorded maintenance provider for asset = #{object_key}"

    unless new_record?
      unless maintenance_provider_updates.empty?
        event = maintenance_provider_updates.last
        self.maintenance_provider_type = event.maintenance_provider_type
        save
      end
    end
  end

  # Forces an update of an assets scheduled replacement. This performs an update on the record.
  def update_scheduled_replacement

    Rails.logger.info "Updating the scheduled replacement/rehabilitation for asset = #{object_key}"

    unless new_record?
      unless schedule_replacement_updates.empty?
        event = schedule_replacement_updates.last
        self.scheduled_replacement_year = event.replacement_year unless event.replacement_year.nil?
        self.scheduled_rehabilitation_year = event.rebuild_year unless event.rebuild_year.nil?
        self.scheduled_by_user = true
        save
      end
    end
  end
  # Forces an update of an assets scheduled disposition

  def update_scheduled_disposition

    Rails.logger.info "Updating the scheduled disposition for asset = #{object_key}"

    unless new_record?
      unless schedule_disposition_updates.empty?
        event = schedule_disposition_updates.last
        self.scheduled_disposition_date = event.disposition_date
        save
      end
    end
  end

  # Creates a duplicate that has all asset-specific attributes nilled
  def copy(cleanse = true)
    a = dup
    a.cleanse if cleanse
    a
  end

  # calculate the year that the asset will need replacing based on
  # a policy
  def calculate_replacement_year(policy = nil)
    # Make sure we are working with a concrete asset class
    asset = is_typed? ? self : Asset.get_typed_asset(self)

    # Get the policy to use
    policy = policy.nil? ? asset.policy : policy
    class_name = policy.service_life_calculation_type.class_name
    # determine the last year that the vehicle is viable based on the policy
    last_year_for_service = calculate(asset, policy, class_name)
    # the asset will need replacing the next year
    return last_year_for_service + 1

  end
  # calculate the estimated year that the asset will need replacing based on
  # a policy
  def calculate_estimated_replacement_year(policy = nil)
    # Make sure we are working with a concrete asset class
    asset = is_typed? ? self : Asset.get_typed_asset(self)

    # Get the policy to use
    policy = policy.nil? ? asset.policy : policy
    class_name = policy.condition_estimation_type.class_name
    # estimate the last year that the asset will be servicable
    last_year_for_service = calculate(asset, policy, class_name, 'last_servicable_year')
    # the asset will need replacing the next year
    return last_year_for_service + 1

  end

  def searchable_fields
    SEARCHABLE_FIELDS
  end

  # nils out all fields identified to be cleansed
  def cleanse
    cleansable_fields.each do |field|
      self[field] = nil
    end
  end

  # Update the SOGR for an asset
  def update_sogr(policy = nil)
    update_asset_state(policy)
  end
  
  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # updates the calculated values of an asset
  def update_asset_state(policy = nil)
    Rails.logger.info "Updating SOGR for asset = #{object_key}"

    # Make sure we are working with a concrete asset class
    asset = is_typed? ? self : Asset.get_typed_asset(self)

    # Get the policy to use
    policy = policy.nil? ? asset.policy : policy

    # exit if we can find a policy to work on
    if policy.nil?
      Rails.logger.warn "Can't find a policy for asset = #{object_key}"
      return
    end

    # returns the year in which the asset should be replaced based on the policy and asset
    # characteristics
    begin
      # see what metric we are using to determine the service life of the asset
      class_name = policy.service_life_calculation_type.class_name
      asset.policy_replacement_year = calculate(asset, policy, class_name)
      # automatically flag the replacement year unless the user has set one
      unless asset.scheduled_by_user == true
        # If the asset is in backlog set the scheduled year to the current FY year
        if asset.policy_replacement_year < current_fiscal_year_year
          Rails.logger.debug "Asset is in backlog. Setting scheduled replacement year to #{current_fiscal_year_year}"
          asset.scheduled_replacement_year = current_fiscal_year_year
        else
          Rails.logger.debug "Setting scheduled replacement year to #{asset.policy_replacement_year}"
          asset.scheduled_replacement_year = asset.policy_replacement_year
        end
      end
    rescue Exception => e
      Rails.logger.warn e.message
    end

    # Estimate the year that the asset will need replacing
    begin
      class_name = policy.condition_estimation_type.class_name
      asset.estimated_replacement_year = calculate(asset, policy, class_name, 'last_servicable_year')
    rescue Exception => e
      Rails.logger.warn e.message
    end

    # returns the cost for replacing the asset in the replacement year based on the policy
    begin
      class_name = policy.cost_calculation_type.class_name
      asset.estimated_replacement_cost = calculate(asset, policy, class_name)
    rescue Exception => e
      Rails.logger.warn e.message
    end

    # determine if the asset is in backlog
    begin
      # Check to see if the asset should have been replaced before this year
      replacement_year = asset.policy_replacement_year
      asset.in_backlog = replacement_year < Date.today.year
    rescue Exception => e
      Rails.logger.warn e.message
    end

    # Update the estimated condition
    begin
      # see what metric we are using to estimate the condition of the asset
      class_name = policy.condition_estimation_type.class_name
      asset.estimated_condition_rating = calculate(asset, policy, class_name)
      asset.estimated_condition_type = ConditionType.from_rating(asset.estimated_condition_rating)
    rescue Exception => e
      Rails.logger.warn e.message
    end

    # save changes to this asset
    asset.save
  end

  # updates the estimated value of an asset
  def update_asset_value(policy = nil)
    Rails.logger.info "Updating estimated value for asset = #{object_key}"

    # Make sure we are working with a concrete asset class
    asset = is_typed? ? self : Asset.get_typed_asset(self)

    # Get the policy to use
    policy = policy.nil? ? asset.policy : policy

    # exit if we can find a policy to work on
    if policy.nil?
      Rails.logger.warn "Can't find a policy for asset = #{object_key}"
      return
    end

    begin
      # see what metric we are using to determine the service life of the asset
      class_name = policy.depreciation_calculation_type.class_name
      asset.estimated_value = calculate(asset, policy, class_name)
      # save changes to this asset
      asset.save
    rescue Exception => e
      Rails.logger.warn e.message
    end
  end

  def cleansable_fields
    CLEANSABLE_FIELDS
  end

  # Set resonable defaults for a new asset
  def set_defaults
    self.manufacture_year ||= 2000
    self.expected_useful_life ||= 0
  end

  #------------------------------------------------------------------------------
  #
  # Private Methods
  #
  #------------------------------------------------------------------------------
  private

  # Calls a calculate method on a Calculator class to perform a condition or cost calculation
  # for the asset. The method name defaults to x.calculate(asset) but other methods
  # with the same signature can be passed in
  def calculate(asset, policy, class_name, target_method = 'calculate')
    begin
      Rails.logger.debug "#{class_name}, #{target_method}"
      # create an instance of this class and call the method
      calculator_instance = class_name.constantize.new(policy)
      Rails.logger.debug "Instance created #{calculator_instance}"
      method_object = calculator_instance.method(target_method)
      Rails.logger.debug "Instance method created #{method_object}"
      method_object.call(asset)
    rescue Exception => e
      Rails.logger.error e.message
      raise RuntimeError.new "#{class_name} calculation failed for asset #{asset.object_key} and policy #{policy.name}"
    end
  end

end
