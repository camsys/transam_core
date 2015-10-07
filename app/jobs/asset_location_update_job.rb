#------------------------------------------------------------------------------
#
# AssetLocationUpdateJob
#
# Updates an assets location
#
#------------------------------------------------------------------------------
class AssetLocationUpdateJob < AbstractAssetUpdateJob
  
  def execute_job(asset)     
    asset.update_location
  end

  def prepare
    Rails.logger.debug "Executing AssetLocationUpdateJob at #{Time.now.to_s} for Asset #{object_key}"    
  end
  
end