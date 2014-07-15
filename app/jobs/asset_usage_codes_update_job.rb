#------------------------------------------------------------------------------
#
# AssetUsageCodesUpdateJob
#
# Updates an assets condition
#
#------------------------------------------------------------------------------
class AssetUsageCodesUpdateJob < AbstractAssetUpdateJob
  
  def execute_job(asset)       
    asset.update_usage_codes
  end

  def prepare
    Rails.logger.debug "Executing AssetUsageCodesUpdateJob at #{Time.now.to_s} for Asset #{object_key}"    
  end
  
end