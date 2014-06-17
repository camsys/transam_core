#------------------------------------------------------------------------------
#
# AssetUsageCodesUpdateJob
#
# Updates an assets condition
#
#------------------------------------------------------------------------------
class AssetUsageCodesUpdateJob < Job
  
  attr_accessor :object_key
  
  def run    
    asset = Asset.find_by_object_key(object_key)
    if asset
      # Make sure the asset is typed
      a = Asset.get_typed_asset(asset)
      a.update_usage_codes
    else
      raise RuntimeError, "Can't find Asset with object_key #{object_key}"
    end
  end

  def prepare
    Rails.logger.debug "Executing AssetUsageCodesUpdateJob at #{Time.now.to_s} for Asset #{object_key}"    
  end
  
  def check    
    raise ArgumentError, "object_key can't be blank " if object_key.blank?
  end
  
  def initialize(object_key)
    super
    self.object_key = object_key
  end

end