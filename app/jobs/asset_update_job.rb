#------------------------------------------------------------------------------
#
# AssetUpdateJob
#
# Performs all updates on an asset
#
#------------------------------------------------------------------------------
class AssetUpdateJob < AbstractAssetUpdateJob
  
  def requires_sogr_update?  
    true
  end  
  
  def execute_job(asset)     

    # generic asset updates
    asset.update_service_status
    asset.update_condition
    asset.update_maintenance_provider
    asset.update_scheduled_replacement
    asset.update_scheduled_rehabilitation
    asset.update_scheduled_disposition
    asset.update_estimated_value
      
  end

  def prepare
    Rails.logger.debug "Executing AssetUpdateJob at #{Time.now.to_s} for Asset #{object_key}"    
  end
  
end
