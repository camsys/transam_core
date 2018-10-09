class TransamAsset < TransamAssetRecord

  include TransamObjectKey
  include FiscalYear

  actable as: :transam_assetible

  # Before the asset is updated we may need to update things like estimated
  # replacement cost if they updated other things
  # updates the calculated values of an asset
  after_save      :check_policy_rule
  after_save      :update_asset_state
  before_validation   :cleanup_others

  belongs_to  :organization
  belongs_to  :asset_subtype
  belongs_to  :manufacturer
  belongs_to  :manufacturer_model
  belongs_to  :vendor
  belongs_to  :operator, :class_name => 'Organization'
  belongs_to  :title_ownership_organization, :class_name => 'Organization'
  belongs_to  :lienholder, :class_name => 'Organization'

  # an upload can be added by bulk updates - new inventory
  belongs_to :upload

  has_and_belongs_to_many     :asset_groups, join_table: :asset_groups_assets, foreign_key: :transam_asset_id

  # Each asset can have 0 or more dependents (parent-child relationships)
  has_many    :dependents,  :class_name => 'TransamAsset', :foreign_key => :parent_id, :dependent => :nullify, :inverse_of => :parent
  accepts_nested_attributes_for :dependents, :reject_if => :all_blank, :allow_destroy => true

  # Facilities can have many vehicles stored on their premises
  has_many    :occupants,   :class_name => 'TransamAsset', :foreign_key => :location_id, :dependent => :nullify

  belongs_to :parent, class_name: 'TransamAsset', foreign_key: :parent_id
  belongs_to :location, class_name: 'TransamAsset', foreign_key: :location_id

  has_many :serial_numbers, as: :identifiable, inverse_of: :identifiable, dependent: :destroy
  accepts_nested_attributes_for :serial_numbers

  # each asset has zero or more condition updates
  has_many   :condition_updates, -> {where :asset_event_type_id => ConditionUpdateEvent.asset_event_type.id }, :class_name => "ConditionUpdateEvent", :foreign_key => :transam_asset_id
  accepts_nested_attributes_for :condition_updates, :reject_if => Proc.new{|ae| ae['assessed_rating'].blank? }, :allow_destroy => true

  # each asset has zero or more scheduled replacement updates
  has_many   :schedule_replacement_updates, -> {where :asset_event_type_id => ScheduleReplacementUpdateEvent.asset_event_type.id }, :class_name => "ScheduleReplacementUpdateEvent", :foreign_key => :transam_asset_id

  # each asset has zero or more scheduled rehabilitation updates
  has_many   :schedule_rehabilitation_updates, -> {where :asset_event_type_id => ScheduleRehabilitationUpdateEvent.asset_event_type.id }, :class_name => "ScheduleRehabilitationUpdateEvent", :foreign_key => :transam_asset_id

  # each asset has zero or more recorded rehabilitation events
  has_many   :rehabilitation_updates, -> {where :asset_event_type_id => RehabilitationUpdateEvent.asset_event_type.id}, :class_name => "RehabilitationUpdateEvent", :foreign_key => :transam_asset_id
  accepts_nested_attributes_for :rehabilitation_updates, :reject_if => Proc.new{|ae| ae['total_cost'].blank? }, :allow_destroy => true

  # each asset has zero or more scheduled disposition updates
  has_many   :schedule_disposition_updates, -> {where :asset_event_type_id => ScheduleDispositionUpdateEvent.asset_event_type.id }, :class_name => "ScheduleDispositionUpdateEvent", :foreign_key => :transam_asset_id

  # each asset has zero or more service status updates
  has_many   :service_status_updates, -> {where :asset_event_type_id => ServiceStatusUpdateEvent.asset_event_type.id }, :class_name => "ServiceStatusUpdateEvent", :foreign_key => :transam_asset_id
  accepts_nested_attributes_for :service_status_updates, :reject_if => Proc.new{|ae| ae['service_status_type_id'].blank? }, :allow_destroy => true

  # each asset has zero or more disposition updates
  has_many   :disposition_updates, -> {where :asset_event_type_id => DispositionUpdateEvent.asset_event_type.id }, :class_name => "DispositionUpdateEvent", :foreign_key => :transam_asset_id

  # each asset has zero or more early disposition requests
  has_many   :early_disposition_requests, -> {where :asset_event_type_id => EarlyDispositionRequestUpdateEvent.asset_event_type.id }, :class_name => "EarlyDispositionRequestUpdateEvent", :foreign_key => :transam_asset_id

  # each asset has zero or more location updates.
  has_many   :location_updates, -> {where :asset_event_type_id => LocationUpdateEvent.asset_event_type.id }, :class_name => "LocationUpdateEvent", :foreign_key => :transam_asset_id
  accepts_nested_attributes_for :location_updates, :reject_if => Proc.new{|ae| ae['parent_key'].blank? }, :allow_destroy => true

  # Each asset has zero or more images. Images are deleted when the asset is deleted
  has_many    :images,      :as => :imagable,       :dependent => :destroy

  # Each asset has zero or more documents. Documents are deleted when the asset is deleted
  has_many    :documents,   :as => :documentable, :dependent => :destroy

  # Each asset has zero or more comments. Documents are deleted when the asset is deleted
  has_many    :comments,    :as => :commentable,  :dependent => :destroy

  # Each asset has zero or more tasks. Tasks are deleted when the asset is deleted
  has_many    :tasks,       :as => :taskable,     :dependent => :destroy

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------

  validates :asset_subtype_id, presence: true
  validates :organization_id, presence: true
  validates :asset_tag, presence: true, uniqueness: {scope: :organization_id }
  validates :purchase_cost, presence: true
  validates :purchase_cost, numericality: { greater_than_or_equal_to: 0 }
  validates :purchased_new, inclusion: { in: [ true, false ] }
  validates :purchase_date, presence: true #temporarily force in case used in other places but eventually will not be required
  validates :in_service_date, presence: true
  validates :manufacturer_id, inclusion: {in: Manufacturer.where(code: 'ZZZ').pluck(:id)}, if: Proc.new{|a| a.manufacturer_id.present? && a.other_manufacturer.present?}
  validates :manufacturer_model_id, inclusion: {in: ManufacturerModel.where(name: 'Other').pluck(:id)}, if: Proc.new{|a| a.manufacturer_model_id.present? && a.other_manufacturer_model.present?}

  validate        :object_key_is_not_asset_tag

  #validates :quantity, numericality: { greater_than: 0 }
  #validates :quantity, presence: true
  #validates :quantity_units, presence: true

  #-----------------------------------------------------------------------------
  # Scopes
  #-----------------------------------------------------------------------------

  # Returns a list of assets that have been disposed
  scope :disposed,    -> { where.not(disposition_date: nil) }

  # Returns a list of assets that are still operational
  scope :operational, -> { where(TransamAsset.arel_table[:asset_tag].not_eq(TransamAsset.arel_table[:object_key])).where(disposition_date: nil) }

  # Returns a list of asset that in early replacement
  scope :early_replacement, -> { where('policy_replacement_year is not NULL and scheduled_replacement_year is not NULL and scheduled_replacement_year < policy_replacement_year') }

  FORM_PARAMS = [
      :organization_id,
      :asset_subtype_id,
      :asset_tag,
      :external_id,
      :description,
      :manufacturer_id,
      :other_manufacturer,
      :manufacturer_model_id,
      :other_manufacturer_model,
      :manufacture_year,
      :purchase_cost,
      :purchase_date,
      :purchased_new,
      :in_service_date,
      :vendor_id,
      :other_vendor,
      :operator_id,
      :other_operator,
      :title_number,
      :title_ownership_organization_id,
      :other_titel_ownership_organization,
      :lienholder_id,
      :other_lienholder,
      :parent_id,
      :quantity,
      :quantity_unit,
      {condition_updates_attributes: ConditionUpdateEvent.allowable_params},
      {service_status_updates_attributes: ServiceStatusUpdateEvent.allowable_params},
      {location_updates_attributes: LocationUpdateEvent.allowable_params},
      {rehabilitation_updates_attributes: RehabilitationUpdateEvent.allowable_params}
  ]

  CLEANSABLE_FIELDS = [
      'object_key',
      'asset_tag',
      'external_id',
      'disposition_date',
      'policy_replacement_year',
      'scheduled_replacement_year',
      'scheduled_replacement_cost',
      'early_replacement_reason',
      'in_backlog',
      'scheduled_rehabilitation_year',
      'scheduled_disposition_year'
  ]

  SEARCHABLE_FIELDS = [
      :object_key,
      :asset_tag,
      :external_id,
      :description,
      :manufacturer_model,
      :title_number
  ]


  # Factory method to return a strongly typed subclass of a new asset
  # based on the asset_base_class_name
  def self.new_asset(asset_seed_class_name, params={})

    asset_class_name = asset_seed_class_name.try(:class_name, opts: params) || asset_seed_class_name.class_name
    asset = asset_class_name.constantize.new
    asset.send("#{asset_seed_class_name.class.to_s.foreign_key}=",asset_seed_class_name.id)
    return asset

  end

  callable_by_submodel def self.very_specific
    klass = self.all
    assoc = klass.column_names.select{|col| col.end_with? 'ible_type'}.first
    assoc_arr = Hash.new
    assoc_arr[assoc] = nil
    t = klass.distinct.where.not(assoc_arr).pluck(assoc)

    while t.count == 1 && assoc.present?
      id_col = assoc[0..-6] + '_id'
      klass = t.first.constantize.where(id: klass.pluck(id_col))
      assoc = klass.column_names.select{|col| col.end_with? 'ible_type'}.first
      if assoc.present?
        assoc_arr = Hash.new
        assoc_arr[assoc] = nil
        t = klass.distinct.where.not(assoc_arr).pluck(assoc)
      end
    end

    return klass

  end

  # mirror method on Asset to get typed version
  def self.get_typed_asset(asset)
    if asset
      asset = asset.very_specific

      seed_assoc = Rails.application.config.asset_seed_class_name.underscore
      if asset.class.to_s != asset.send(seed_assoc).class_name(asset: asset)
        asset = asset.send(seed_assoc).class_name(asset: asset).constantize.find_by(object_key: asset.object_key)
      end

      asset
    end
  end

  def very_specific
    a = self.specific

    while a.try(:specific).present? && a.specific != a
      a = a.specific
    end

    return a
  end

  def cleansable_fields
    arr = CLEANSABLE_FIELDS.dup
    a = self.specific

    while a.try(:specific).present? && a.specific != a
      arr << a.class::CLEANSABLE_FIELDS.dup
      a = a.specific
    end

    arr << a.class::CLEANSABLE_FIELDS.dup

    return arr.flatten
  end

  def searchable_fields
    typed_self = TransamAsset.get_typed_asset(self)

    arr = (defined? typed_self.class::SEARCHABLE_FIELDS) ? typed_self.class::SEARCHABLE_FIELDS.dup : []


    if typed_self.class.superclass.name != "TransamAssetRecord"
      arr << typed_self.class.superclass::SEARCHABLE_FIELDS if defined? typed_self.class.superclass::SEARCHABLE_FIELDS
    end

    a = typed_self.class.try(:acting_as_model)
    while a.present?
      arr << a::SEARCHABLE_FIELDS.dup if defined? a::SEARCHABLE_FIELDS
      a = a.try(:acting_as_model)
    end

    return arr.flatten
  end

  def event_classes
    typed_asset = TransamAsset.get_typed_asset(self)

    a = []
    # Use reflection to return the list of has many associatiopns and filter those which are
    # events
    typed_asset.class.reflect_on_all_associations(:has_many).each do |assoc|
      a << assoc.klass if assoc.class_name.end_with? 'UpdateEvent'
    end

    if typed_asset.class.superclass.name != "TransamAssetRecord"
      klass = very_specific.class.superclass
      klass.reflect_on_all_associations(:has_many).each do |assoc|
        a << assoc.klass if assoc.class_name.end_with? 'UpdateEvent'
      end
    end

    a.uniq
  end

  def asset_events(unscoped=false)
    typed_asset = TransamAsset.get_typed_asset(self)

    events = []
    event_classes.each do |e|
      assoc_name = e.name.gsub('Event', '').underscore.pluralize
      assoc_name = 'early_disposition_requests' if assoc_name == 'early_disposition_request_updates'
      events << typed_asset.send(assoc_name).ids
    end
    if unscoped
      AssetEvent.unscoped.where(id: events.flatten)
    else
      AssetEvent.where(id: events.flatten)
    end

  end

  # returns the list of events associated with this asset ordered by date, newest first
  def history
    asset_events(true).order('event_date DESC, created_at DESC')
  end


  # Instantiate an asset event of the appropriate type.
  def build_typed_event(asset_event_type_class)
    # Could also add:  raise ArgumentError 'Asset Must be strongly typed' unless is_typed?

    # DO NOT cast to concrete type.  Want to enforce that client has a concrete asset
    unless self.event_classes.include? asset_event_type_class
      raise ArgumentError, 'Invalid Asset Event Type'
    end

    assoc = asset_event_type_class.reflect_on_association(:transam_asset).class_name
    typed_asset = TransamAsset.get_typed_asset(self)
    asset_event_type_class.new(transam_asset: (typed_asset.type_of? assoc) ? typed_asset : typed_asset.send(assoc.underscore))
  end

  def asset_type_id
    asset_subtype.asset_type_id
  end

  def asset_type
    asset_subtype.asset_type
  end

  def disposed?
    disposition_date.present?
  end

  # Returns true if the asset can be disposed in the next planning cycle,
  # false otherwise
  def disposable?( include_early_disposal_request_approved_via_transfer = false)
    return false if disposed?
    # otherwise check the policy year and see if it is less than or equal to
    # the current planning year
    return false if policy_replacement_year.blank?

    if policy_replacement_year <= current_planning_year_year
      # After ESL disposal
      true
    else
      # Prior ESL disposal request
      last_request = early_disposition_requests.last
      if include_early_disposal_request_approved_via_transfer
        last_request.try(:is_approved?)
      else
        last_request.try(:is_unconditional_approved?)
      end
    end
  end

  # Returns true if the asset can be requested for early disposal
  def eligible_for_early_disposition_request?
    return false if disposed?
    # otherwise check the policy year and see if it is less than or equal to
    # the current planning year
    return false if policy_replacement_year.blank?

    if policy_replacement_year <= current_planning_year_year
      # Eligible for after ESL disposal
      false
    else
      # Prior ESL disposal request
      last_request = early_disposition_requests.last
      # No previous request or was rejected
      !last_request || last_request.try(:is_rejected?)
    end
  end

  def policy
    organization.get_policy
  end

  #-----------------------------------------------------------------------------
  # Return the policy analyzer for this asset. If a policy is not provided the
  # default policy for the asset is used
  #-----------------------------------------------------------------------------
  def policy_analyzer(policy_to_use=nil)
    if policy_to_use.blank?
      policy_to_use = policy
    end
    policy_analyzer = Rails.application.config.policy_analyzer.constantize.new(TransamAsset.get_typed_asset(self), policy_to_use)
  end

  def expected_useful_life
    purchased_new ? policy_analyzer.get_min_service_life_months : policy_analyzer.get_min_used_purchase_service_life_months
  end

  def policy_rehabilitation_year
    # Check for rehabilitation policy events
    begin
      # Use the calculator to calculate the policy rehabilitation fiscal year
      calculator = RehabilitationYearCalculator.new
      return calculator.calculate(TransamAsset.get_typed_asset(self))
    rescue Exception => e
      Rails.logger.warn e.message
      Rails.logger.error e.backtrace
    end
  end

  def estimated_replacement_year
    # Estimate the year that the asset will need replacing
    begin
      class_name = policy_analyzer.get_condition_estimation_type.class_name
      calculate(TransamAsset.get_typed_asset(self), class_name, 'last_servicable_year') + 1
    rescue Exception => e
      Rails.logger.warn e.message
      Rails.logger.error e.backtrace
    end
  end

  def estimated_replacement_cost
    if self.policy_replacement_year < current_planning_year_year
      start_date = start_of_fiscal_year(scheduled_replacement_year)
    else
      start_date = start_of_fiscal_year(policy_replacement_year)
    end
    # Update the estimated replacement costs
    class_name = policy_analyzer.get_replacement_cost_calculation_type.class_name
    calculator_instance = class_name.constantize.new
    (calculator_instance.calculate_on_date(self, start_date)+0.5).to_i
  end

  # Returns true if an asset is scheduled for disposition
  def scheduled_for_disposition?
    (scheduled_disposition_year.present? and disposed? == false)
  end

  def is_early_replacement?
    policy_replacement_year && scheduled_replacement_year && scheduled_replacement_year < policy_replacement_year
  end

  def update_early_replacement_reason(reason = nil)
    if is_early_replacement?
      self.early_replacement_reason = reason
    else
      self.early_replacement_reason = nil
    end
  end

  def formatted_early_replacement_reason
    if early_replacement_reason.present?
      early_replacement_reason
    else
      '(Reason not provided)'
    end
  end

  def parent_name
    parent.to_s unless parent.nil?
  end

  def parent_key=(object_key)
    self.parent = TransamAsset.find_by_object_key(object_key)
  end
  def parent_key
    parent.object_key if parent
  end

  def location_name
    location.to_s unless location.nil?
  end

  def location_key=(object_key)
    self.location = TransamAsset.find_by_object_key(object_key)
  end
  def location_key
    location.object_key if location
  end

  def cost
    purchase_cost
  end

  # returns the number of years since the asset was placed in service.
  def age(on_date=Date.today)
    age_in_years = if in_service_date.nil?
                     0
                   else
                     ((on_date.year * 12 + on_date.month) - (in_service_date.year * 12 + in_service_date.month))/12.0
                   end
    [(age_in_years).floor, 0].max
  end

  def service_status_type
    if disposed?
      ServiceStatusType.find_by(name: 'Disposed')
    else
      ServiceStatusType.find_by(id: service_status_updates.last.try(:service_status_type_id))
    end
  end

  def last_rehabilitation_date
    rehabilitation_updates.last.try(:event_date)
  end

  def reported_condition_date
    # if dependents.count > 0
    #   dependents.order(:reported_condition_date).pluck(:reported_condition_date).last
    # else
    #   condition_updates.last.try(:event_date)
    # end
    condition_updates.last.try(:event_date)
  end
  def reported_condition_rating
    # if dependents.count > 0
    #   policy_analyzer.get_condition_rollup_calculation_type.class_name.constantize.new.calculate(self)
    # else
    #   condition_updates.last.try(:assessed_rating)
    # end
    condition_updates.last.try(:assessed_rating)
  end
  def reported_condition_type
    ConditionType.from_rating(reported_condition_rating)
  end

  def estimated_condition_rating
    # Estimate the year that the asset will need replacing amd the estimated
    # condition of the asset
    begin
      class_name = policy_analyzer.get_condition_estimation_type.class_name
      calculate(TransamAsset.get_typed_asset(self), class_name)
    rescue Exception => e
      Rails.logger.warn e.message
      Rails.logger.error e.backtrace
    end
  end
  def estimated_condition_type
    ConditionType.from_rating(estimated_condition_rating)
  end


  protected

  # updates the calculated values of an asset
  def update_asset_state

    return unless self.replacement_by_policy? || self.replacement_pinned?

    Rails.logger.debug "Updating SOGR for transam asset = #{object_key}"

    if disposed?
      Rails.logger.debug "Asset #{object_key} is disposed"
    end

    # returns the year in which the asset should be replaced based on the policy and asset
    # characteristics
    begin
      # store old policy replacement year for use later
      old_policy_replacement_year = policy_replacement_year

      # see what metric we are using to determine the service life of the asset
      class_name = policy_analyzer.get_service_life_calculation_type.class_name
      update_columns(policy_replacement_year: calculate(TransamAsset.get_typed_asset(self), class_name))

      if self.scheduled_replacement_year.nil? or self.scheduled_replacement_year == old_policy_replacement_year
        Rails.logger.debug "Setting scheduled replacement year to #{policy_replacement_year}"
        update_columns(scheduled_replacement_year: self.policy_replacement_year, in_backlog: false)
      end
      # If the asset is in backlog set the scheduled year to the current FY year
      if self.scheduled_replacement_year < current_planning_year_year
        Rails.logger.debug "Asset is in backlog. Setting scheduled replacement year to #{current_planning_year_year}"
        update_columns(scheduled_replacement_year: current_planning_year_year, in_backlog: true)
      end
    rescue Exception => e
      Rails.logger.warn e.message
      Rails.logger.warn e.backtrace
    end

    # If the policy replacement year changes we need to check to see if the asset
    # is in backlog and update the scheduled replacement year to the first planning
    # year
    if self.policy_replacement_year < current_planning_year_year
      update_columns(scheduled_replacement_year: current_planning_year_year, in_backlog: true)
    else
      update_columns(in_backlog: false)
    end

    Rails.logger.debug "New scheduled_replacement_year = #{self.scheduled_replacement_year}"
    # Get the calculator class from the policy analyzer
    class_name = policy_analyzer.get_replacement_cost_calculation_type.class_name
    calculator_instance = class_name.constantize.new
    start_date = start_of_fiscal_year(scheduled_replacement_year) unless scheduled_replacement_year.blank?
    Rails.logger.debug "Start Date = #{start_date}"
    update_columns(scheduled_replacement_cost: (calculator_instance.calculate_on_date(self, start_date)+0.5).to_i)

    #self.early_replacement_reason = nil if check_early_replacement && !is_early_replacement?
  end

  def check_policy_rule

    policy.find_or_create_asset_type_rule self.asset_subtype.asset_type

    typed_asset = TransamAsset.get_typed_asset self
    if (typed_asset.respond_to? :fuel_type)
      policy.find_or_create_asset_subtype_rule asset_subtype, typed_asset.fuel_type
    else
      policy.find_or_create_asset_subtype_rule asset_subtype
    end
  end

  def calculate_term_estimation(on_date)
    if on_date
      TermEstimationCalculator.new.calculate_on_date(self, on_date)
    else
      0
    end
  end

  private

  # Calls a calculate method on a Calculator class to perform a condition or cost calculation
  # for the asset. The method name defaults to x.calculate(asset) but other methods
  # with the same signature can be passed in
  def calculate(asset, class_name, target_method = 'calculate')
    begin
      Rails.logger.debug "#{class_name}, #{target_method}"
      # create an instance of this class and call the method
      calculator_instance = class_name.constantize.new
      Rails.logger.debug "Instance created #{calculator_instance}"
      method_object = calculator_instance.method(target_method)
      Rails.logger.debug "Instance method created #{method_object}"
      method_object.call(asset)
    rescue Exception => e
      Rails.logger.error e.message
      Rails.logger.error e.backtrace
      raise RuntimeError.new "#{class_name} calculation failed for asset #{asset.object_key} and policy #{policy.name}"
    end
  end

  def object_key_is_not_asset_tag
    unless self.asset_tag.nil? || self.object_key.nil?
      if self.asset_tag == self.object_key
        @errors.add(:asset_tag, "should not be the same as the object key")
      end
    end
  end

  def cleanup_others
    # other_manufacturer only has value when type is one of Other types
    if self.changes.include?("manufacturer_id") && self.other_manufacturer.present?
      self.other_manufacturer = nil unless Manufacturer.where(code: 'ZZZ').pluck(:id).include?(self.manufacturer_id)
    end

    # other_manufacturer_model only has value when model type is one of Other types
    if self.changes.include?("manufacturer_model_id") && self.other_manufacturer_model.present?
      self.other_manufacturer_model = nil unless ManufacturerModel.where(name: 'Other').pluck(:id).include?(self.manufacturer_model_id)
    end

    if self.changes.include?("vendor_id") && self.other_vendor.present?
      self.other_vendor = nil if self.vendor_id
    end

    if self.changes.include?("operator_id") && self.other_operator.present?
      self.other_operator = nil if self.operator_id
    end

    if self.changes.include?("title_ownership_organization_id") && self.other_title_ownership_organization.present?
      self.other_titel_ownership_organization = nil if self.title_ownership_organization_id
    end

    if self.changes.include?("lienholder_id") && self.other_lienholder.present?
      self.other_lienholder = nil if self.lienholder_id
    end
  end
end
