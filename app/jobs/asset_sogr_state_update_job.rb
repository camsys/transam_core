#------------------------------------------------------------------------------
#
# AssetSogrStateUpdateJob
#
# Updates an assets SOGR state
#
#------------------------------------------------------------------------------
class AssetSogrStateUpdateJob < AbstractAssetUpdateJob
  
  def execute_job(asset)       
    asset.update_asset_state
  end

  def prepare
    Rails.logger.debug "Executing AssetSogrStateUpdateJob at #{Time.now.to_s} for Asset #{object_key}"    
  end
  
end