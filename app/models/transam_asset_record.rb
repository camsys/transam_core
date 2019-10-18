# most class and instance methods of assets acting as transam asset can be accessed from the TransamAsset model
# but there are some methods that are across all classes but acting as themselves (rev vehicle, facility, etc)
# so they inherit from TransamAssetRecord
class TransamAssetRecord < ActiveRecord::Base
  self.abstract_class = true

  after_validation :check_for_duplicate_object_keys

  class << self
    attr_accessor :child_asset_class
  end

  # Returns whether this class is an abstract class or not.
  def self.child_asset_class?
    defined?(@child_asset_class) && @child_asset_class == true
  end

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

  def to_param
    object_key
  end

  def to_s
    asset_tag
  end

  # Creates a duplicate that has all asset-specific attributes nilled
  def copy(cleanse = true)
    a = dup
    a.cleanse if cleanse
    a
  end

  # nils out all fields identified to be cleansed
  def cleanse
    cleansable_fields.each do |field|
      send(:"#{field}=", nil) # Rather than set methods directly, delegate to setters.  This supports aliased attributes
    end
  end

  def transfer new_organization_id
    org = Organization.where(:id => new_organization_id).first

    transferred_asset = TransamAsset.get_typed_asset(self).copy false
    transferred_asset.object_key = nil
    transferred_asset.external_id = nil

    transferred_asset.disposition_date = nil
    transferred_asset.in_service_date = nil
    transferred_asset.purchase_date = self.disposition_date
    transferred_asset.purchased_new = false
    transferred_asset.purchase_cost = self.disposition_updates.last.sales_proceeds
    transferred_asset.pcnt_capital_responsibility = nil
    transferred_asset.title_ownership_organization_id = nil
    transferred_asset.other_title_ownership_organization = nil
    transferred_asset.operator_id = nil
    transferred_asset.other_operator = nil

    transferred_asset.organization = org
    transferred_asset.generate_object_key(:object_key)
    transferred_asset.asset_tag = transferred_asset.object_key

    if self.serial_numbers.count > 0
      self.serial_numbers.each do |serial_num|
        transferred_asset.serial_numbers << serial_num.dup
      end
    end

    # create last condition, status
    transferred_asset.condition_updates << self.condition_updates.last.dup if self.condition_updates.count > 0
    transferred_asset.service_status_updates << self.service_status_updates.last.dup if self.service_status_updates.count > 0

    transferred_asset.save(:validate => false)

    return transferred_asset
  end

  def allowable_params
    arr = if self.class.child_asset_class?
            typed_asset_params
          else
            dependent_params = []
            TransamAssetRecord.subclasses.each do |sub|
              dependent_params << sub.new.typed_asset_params if sub.child_asset_class?
            end

            typed_asset_params + [:dependents_attributes =>dependent_params.flatten]
          end

    SystemConfigExtension.where(active: true, class_name: 'TransamAsset').pluck(:extension_name).each do |ext_name|
      if ext_name.constantize::ClassMethods.try(:allowable_params)
        arr << ext_name.constantize::ClassMethods.allowable_params
      end
    end

    return arr.flatten

  end

  def typed_asset_params
    arr = self.class::FORM_PARAMS.dup

    if self.class.superclass.name != "TransamAssetRecord"
      arr << self.class.superclass::FORM_PARAMS
    end

    a = self.class.try(:acting_as_model)
    while a.present?
      arr << a::FORM_PARAMS.dup
      a = a.try(:acting_as_model)
    end

    return arr.flatten
  end

  def replacement_by_policy?
    true # all assets in core are in replacement cycle. To plan and/or make exceptions to normal schedule, see CPT.
  end

  def replacement_pinned?
    false # all assets can be locked into place to prevent sched replacement year changes but by default none are locked
  end

  protected

  def check_for_duplicate_object_keys
    if self.errors.details[:object_key].map{|x| x[:error]}.include? :taken
      # send metrics with object_keys that are duplicated
      PutMetricDataService.new.put_metric('TransamAssetCount', 'Count', 1, [
          {
              'Name' => 'Object Key',
              'Value' => self.object_key
          }
      ])

      # send metric to show that there are duplicates - used for alarms
      PutMetricDataService.new.put_metric('DuplicateObjectKeyCount', 'Count', 1, [
          {
              'Name' => 'Class Name',
              'Value' => 'TransamAsset'
          }
      ])
    end
  end

end