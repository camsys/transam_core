#------------------------------------------------------------------------------
#
# AssetConditionUpdateJob
#
# Updates an assets condition
#
#------------------------------------------------------------------------------
class AssetConditionUpdateJob < AbstractAssetUpdateJob
  
  def execute_job(asset)    
    asset.update_condition
  end

  def prepare
    Rails.logger.debug "Executing AssetConditionUpdateJob at #{Time.now.to_s} for Asset #{object_key}"    
  end
  
end