#------------------------------------------------------------------------------
#
# AssetMaintenanceProviderUpdateJob
#
# Updates an assets condition
#
#------------------------------------------------------------------------------
class AssetMaintenanceProviderUpdateJob < AbstractAssetUpdateJob
  
  def execute_job(asset)     
    asset.update_maintenance_provider
  end

  def prepare
    Rails.logger.debug "Executing AssetMaintenanceProviderUpdateJob at #{Time.now.to_s} for Asset #{object_key}"    
  end
  
end