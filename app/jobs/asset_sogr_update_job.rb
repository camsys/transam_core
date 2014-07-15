#------------------------------------------------------------------------------
#
# AssetSogrUpdateJob
#
# Updates an assets SOGR state
#
#------------------------------------------------------------------------------
class AssetSogrUpdateJob < AbstractAssetUpdateJob
  
  def execute_job(asset)       
    asset.update_sogr
  end

  def prepare
    Rails.logger.debug "Executing AssetSogrUpdateJob at #{Time.now.to_s} for Asset #{object_key}"    
  end
  
end