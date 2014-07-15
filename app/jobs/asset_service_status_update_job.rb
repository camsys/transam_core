#------------------------------------------------------------------------------
#
# AssetServiceStatusUpdateJob
#
# Updates an assets service status
#
#------------------------------------------------------------------------------
class AssetServiceStatusUpdateJob < AbstractAssetUpdateJob
  
  def execute_job(asset)       
    asset.update_service_status
  end

  def prepare
    Rails.logger.debug "Executing AssetServiceStatusUpdateJob at #{Time.now.to_s} for Asset #{object_key}"    
  end
  
end