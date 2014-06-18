#------------------------------------------------------------------------------
#
# AssetUpdateJob
#
# Updates all components of an asset
#
#------------------------------------------------------------------------------
class AssetUpdateJob < Job
  
  attr_accessor :object_key
  
  def run    
    asset = Asset.find_by_object_key(object_key)
    if asset
      # Make sure the asset is typed
      a = Asset.get_typed_asset(asset)
      
      # Enter asset specific types of updates here
      # if a.type_of :vehicle
            
      # generic asset updates
      a.update_condition
      a.update_maintenance_provider
      a.update_service_status
      a.update_scheduled_replacement
      a.update_estimated_value
      
    else
      raise RuntimeError, "Can't find Asset with object_key #{object_key}"
    end
  end

  def prepare
    Rails.logger.debug "Executing AssetUpdateJob at #{Time.now.to_s} for Asset #{object_key}"    
  end
  
  def check    
    raise ArgumentError, "object_key can't be blank " if object_key.blank?
  end
  
  def initialize(object_key)
    super
    self.object_key = object_key
  end

end
