class TransamAsset < TransamAssetRecord

  DEFAULT_OTHER_ID = -1
  
  include TransamObjectKey
  include FiscalYear

  actable as: :transam_assetible

  before_validation   :cleanup_others

  belongs_to  :organization
  belongs_to  :asset_subtype
  belongs_to  :manufacturer
  belongs_to  :manufacturer_model
  belongs_to  :vendor

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

  has_many :asset_events,   :foreign_key => :base_transam_asset_id, :dependent => :destroy

  # each asset has zero or more condition updates
  has_many   :condition_updates, -> {where :asset_event_type_id => ConditionUpdateEvent.asset_event_type.id }, :class_name => "ConditionUpdateEvent", :as => :transam_asset
  accepts_nested_attributes_for :condition_updates, :reject_if => Proc.new{|ae| ae['assessed_rating'].blank? }, :allow_destroy => true

  # each asset has zero or more service status updates
  has_many   :service_status_updates, -> {where :asset_event_type_id => ServiceStatusUpdateEvent.asset_event_type.id }, :class_name => "ServiceStatusUpdateEvent", :as => :transam_asset
  accepts_nested_attributes_for :service_status_updates, :reject_if => Proc.new{|ae| ae['service_status_type_id'].blank? }, :allow_destroy => true

  # each asset has zero or more location updates.
  has_many   :location_updates, -> {where :asset_event_type_id => LocationUpdateEvent.asset_event_type.id }, :class_name => "LocationUpdateEvent", :as => :transam_asset
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

  validate :in_service_date_greather_than_purchase_date

  validate        :object_key_is_not_asset_tag

  #validates :quantity, numericality: { greater_than: 0 }
  #validates :quantity, presence: true
  #validates :quantity_units, presence: true

  #-----------------------------------------------------------------------------
  # Scopes
  #-----------------------------------------------------------------------------

  # operational is used in a lot of places but is actually related to ReplaceableAsset (for not disposed or not in transfer)
  # therefore stub this out so always exists so no errors
  scope :operational, -> { all }


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
      :parent_id,
      :quantity,
      :quantity_unit,
      {condition_updates_attributes: ConditionUpdateEvent.allowable_params},
      {service_status_updates_attributes: ServiceStatusUpdateEvent.allowable_params},
      {location_updates_attributes: LocationUpdateEvent.allowable_params}
  ]

  CLEANSABLE_FIELDS = [
      'object_key',
      'asset_tag',
      'external_id',
  ]

  SEARCHABLE_FIELDS = [
      :object_key,
      :asset_tag,
      :external_id,
      :description,
      :manufacturer_model
  ]

  callable_by_submodel def self.asset_seed_class_name
     'AssetType'
  end


  # Factory method to return a strongly typed subclass of a new asset
  # based on the asset_base_class_name
  def self.new_asset(asset_seed_class_name, params={})

    begin
      asset_class_name = asset_seed_class_name.class_name(opts: params)
    rescue ArgumentError => e
      asset_class_name = asset_seed_class_name.class_name
    end

    asset = asset_class_name.constantize.new

    if asset.respond_to? "#{asset_seed_class_name.class.to_s.foreign_key}="
      asset.send("#{asset_seed_class_name.class.to_s.foreign_key}=",asset_seed_class_name.id)
    end

    return asset

  end

  def self.very_specific
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
      if asset.very_specific
        asset = asset.very_specific

        seed_assoc = asset.class.asset_seed_class_name.underscore
        begin
          if asset.class.to_s != asset.send(seed_assoc).class_name(assets: asset)
            asset = asset.send(seed_assoc).class_name(assets: asset).constantize.find_by(object_key: asset.object_key)
          end
        rescue ArgumentError => e
          if asset.class.to_s != asset.send(seed_assoc).class_name
            asset = asset.send(seed_assoc).class_name.constantize.find_by(object_key: asset.object_key)
          end
        end
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

    SystemConfigExtension.where(active: true, class_name: 'TransamAsset').pluck(:extension_name).each do |ext_name|
      if ext_name.constantize::ClassMethods.try(:cleansable_fields)
        arr << ext_name.constantize::ClassMethods.cleansable_fields
      end
    end

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

  # def asset_events(unscoped=false)
  #   typed_asset = TransamAsset.get_typed_asset(self)
  #
  #   events = []
  #   event_classes.each do |e|
  #     assoc_name = e.name.gsub('Event', '').underscore.pluralize
  #     assoc_name = 'early_disposition_requests' if assoc_name == 'early_disposition_request_updates'
  #     events << typed_asset.send(assoc_name).ids
  #   end
  #   if unscoped
  #     AssetEvent.unscoped.where(id: events.flatten)
  #   else
  #     AssetEvent.where(id: events.flatten)
  #   end
  #
  # end

  # returns the list of events associated with this asset ordered by date, newest first
  def history
    asset_events.reorder(event_date: :desc, updated_at: :desc)
  end


  # Instantiate an asset event of the appropriate type.
  def build_typed_event(asset_event_type_class)

    unless self.event_classes.include? asset_event_type_class
      raise ArgumentError, 'Invalid Asset Event Type'
    end

    typed_asset = TransamAsset.get_typed_asset(self)

    if typed_asset.class.superclass.name == "TransamAssetRecord"
      assocs = typed_asset.class.reflect_on_all_associations(:has_many)
    else
      assocs = typed_asset.class.reflect_on_all_associations(:has_many).select{|x| x.class_name == asset_event_type_class.to_s} + typed_asset.class.superclass.reflect_on_all_associations(:has_many)
    end

    idx = 0
    assoc = nil
    while assoc.nil? && idx < assocs.length
      assoc = assocs[idx].name if assocs[idx].class_name == asset_event_type_class.to_s
      idx += 1
    end

    typed_asset.send(assoc).build
  end

  def asset_type_id
    asset_subtype.asset_type_id
  end

  def asset_type
    asset_subtype.asset_type
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
    if try(:disposed?)
      ServiceStatusType.find_by(name: 'Disposed')
    else
      ServiceStatusType.find_by(id: service_status_updates.last.try(:service_status_type_id))
    end
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

  # in single table inheritance we could always pull fuel_type_id cause it would just be nil on assets that didn't have a fuel type
  # we often wrote logic on that assumption so therefore this method ensures that there is always a fuel type id even if it doesn't exist in the database table now that we've moved to class table inheritance
  # a very specific class would respond to this if it exists in the database table
  # if it doesn't, it will try what it acts_as and will eventually hit this method
  def fuel_type_id
    nil
  end


  private

  def in_service_date_greather_than_purchase_date
    unless self.purchase_date.nil? || self.in_service_date.nil?
      if self.in_service_date < self.purchase_date
        @errors.add(:in_service_date, "should be on or after purchase date")
      end
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
      self.other_vendor = nil unless self.vendor_id == DEFAULT_OTHER_ID
    end

    if self.changes.include?("operator_id") && self.other_operator.present?
      self.other_operator = nil unless self.operator_id == DEFAULT_OTHER_ID
    end

    if self.changes.include?("title_ownership_organization_id") && self.other_title_ownership_organization.present?
      self.other_titel_ownership_organization = nil unless self.title_ownership_organization_id == DEFAULT_OTHER_ID
    end

    if self.changes.include?("lienholder_id") && self.other_lienholder.present?
      self.other_lienholder = nil unless self.lienholder_id == DEFAULT_OTHER_ID
    end
  end
end
