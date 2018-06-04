# most class and instance methods of assets acting as transam asset can be accessed from the TransamAsset model
# but there are some methods that are across all classes but acting as themselves (rev vehicle, facility, etc)
# so they inherit from TransamAssetRecord
class TransamAssetRecord < ActiveRecord::Base
  self.abstract_class = true

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
end