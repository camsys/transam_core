class TransamAsset < ApplicationRecord

  include TransamObjectKey

  actable as: :transam_assetible

  belongs_to  :organization, :class_name => 'TransitOperator'
  belongs_to  :asset_subtype
  belongs_to  :manufacturer
  belongs_to  :manufacturer_model
  belongs_to  :vendor
  belongs_to  :operator, :class_name => 'Organization'
  belongs_to  :title_ownership_organization, :class_name => 'Organization'
  belongs_to  :lienholder, :class_name => 'Organization'

  has_and_belongs_to_many     :asset_groups, join_table: :asset_groups_assets, foreign_key: :transam_asset_id

  # Each asset can have 0 or more dependents (parent-child relationships)
  has_many    :dependents,  :class_name => 'TransamAsset', :foreign_key => :parent_id, :dependent => :nullify

  # Facilities can have many vehicles stored on their premises
  has_many    :occupants,   :class_name => 'TransamAsset', :foreign_key => :location_id, :dependent => :nullify

  belongs_to :parent, class_name: 'TransamAsset', foreign_key: :parent_id
  belongs_to :location, class_name: 'TransamAsset', foreign_key: :location_id

  # Each asset has zero or more asset events. These are all events regardless of
  # event type. Events are deleted when the asset is deleted
  has_many   :asset_events, :dependent => :destroy, :foreign_key => :transam_asset_id

  # each asset has zero or more condition updates
  has_many   :condition_updates, -> {where :asset_event_type_id => ConditionUpdateEvent.asset_event_type.id }, :class_name => "ConditionUpdateEvent", :foreign_key => :transam_asset_id

  # each asset has zero or more scheduled replacement updates
  has_many   :schedule_replacement_updates, -> {where :asset_event_type_id => ScheduleReplacementUpdateEvent.asset_event_type.id }, :class_name => "ScheduleReplacementUpdateEvent", :foreign_key => :transam_asset_id

  # each asset has zero or more scheduled rehabilitation updates
  has_many   :schedule_rehabilitation_updates, -> {where :asset_event_type_id => ScheduleRehabilitationUpdateEvent.asset_event_type.id }, :class_name => "ScheduleRehabilitationUpdateEvent", :foreign_key => :transam_asset_id

  # each asset has zero or more recorded rehabilitation events
  has_many   :rehabilitation_updates, -> {where :asset_event_type_id => RehabilitationUpdateEvent.asset_event_type.id}, :class_name => "RehabilitationUpdateEvent", :foreign_key => :transam_asset_id

  # each asset has zero or more scheduled disposition updates
  has_many   :schedule_disposition_updates, -> {where :asset_event_type_id => ScheduleDispositionUpdateEvent.asset_event_type.id }, :class_name => "ScheduleDispositionUpdateEvent", :foreign_key => :transam_asset_id

  # each asset has zero or more service status updates
  has_many   :service_status_updates, -> {where :asset_event_type_id => ServiceStatusUpdateEvent.asset_event_type.id }, :class_name => "ServiceStatusUpdateEvent", :foreign_key => :transam_asset_id

  # each asset has zero or more disposition updates
  has_many   :disposition_updates, -> {where :asset_event_type_id => DispositionUpdateEvent.asset_event_type.id }, :class_name => "DispositionUpdateEvent", :foreign_key => :transam_asset_id

  # each asset has zero or more early disposition requests
  has_many   :early_disposition_requests, -> {where :asset_event_type_id => EarlyDispositionRequestUpdateEvent.asset_event_type.id }, :class_name => "EarlyDispositionRequestUpdateEvent", :foreign_key => :transam_asset_id

  # each asset has zero or more location updates.
  has_many   :location_updates, -> {where :asset_event_type_id => LocationUpdateEvent.asset_event_type.id }, :class_name => "LocationUpdateEvent", :foreign_key => :transam_asset_id

  # Each asset has zero or more images. Images are deleted when the asset is deleted
  has_many    :images,      :as => :imagable,       :dependent => :destroy

  # Each asset has zero or more documents. Documents are deleted when the asset is deleted
  has_many    :documents,   :as => :documentable, :dependent => :destroy

  # Each asset has zero or more comments. Documents are deleted when the asset is deleted
  has_many    :comments,    :as => :commentable,  :dependent => :destroy

  # Each asset has zero or more tasks. Tasks are deleted when the asset is deleted
  has_many    :tasks,       :as => :taskable,     :dependent => :destroy

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
      :other_lienholder
  ]

  # Factory method to return a strongly typed subclass of a new asset
  # based on the asset_base_class_name
  def self.new_asset(asset_base_class_name, params={})

    asset_class_name = asset_base_class_name.class_name
    asset = asset_class_name.constantize.new(params)
    return asset

  end

  def self.allowable_params



    klass = self.all
    a = FORM_PARAMS
    assoc = klass.column_names.select{|col| col.end_with? 'ible_type'}.first
    assoc_arr = Hash.new
    assoc_arr[assoc] = nil
    t = klass.distinct.where.not(assoc_arr).pluck(assoc)

    while t.count == 1
      id_col = assoc[0..-6] + '_id'
      klass = t.first.constantize
      a << klass::FORM_PARAMS
      klass = klass.where(id: klass.pluck(id_col))
      assoc = klass.column_names.select{|col| col.end_with? 'ible_type'}.first
      assoc_arr = Hash.new
      assoc_arr[assoc] = nil
      t = klass.distinct.where.not(assoc_arr).pluck(assoc)
    end

    return a.flatten
  end

  def self.very_specific
    klass = self.all
    assoc = klass.column_names.select{|col| col.end_with? 'ible_type'}.first
    assoc_arr = Hash.new
    assoc_arr[assoc] = nil
    t = klass.distinct.where.not(assoc_arr).pluck(assoc)

    while t.count == 1
      id_col = assoc[0..-6] + '_id'
      klass = t.first.constantize.where(id: klass.pluck(id_col))
      assoc = klass.column_names.select{|col| col.end_with? 'ible_type'}.first
      assoc_arr = Hash.newev
      assoc_arr[assoc] = nil
      t = klass.distinct.where.not(assoc_arr).pluck(assoc)
    end

    return klass

  end

  def very_specific
    a = self.specific

    while a.try(:specific) != a
      a = a.specific
    end

    return a
  end

  def allowable_params
    arr = FORM_PARAMS
    a = self.specific

    while a.try(:specific) != a
      arr << a.class::FORM_PARAMS
      a = a.specific
    end

    return arr.flatten
  end

  def to_s
    asset_tag
  end

  def policy
    asset.organization.get_policy
  end

end
