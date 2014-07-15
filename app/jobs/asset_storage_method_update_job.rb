#------------------------------------------------------------------------------
#
# AssetStorageMethodUpdateJob
#
# Updates an assets condition
#
#------------------------------------------------------------------------------
class AssetStorageMethodUpdateJob < AbstractAssetUpdateJob
  
  def execute_job(asset)       
    asset.update_storage_method
  end

  def prepare
    Rails.logger.debug "Executing AssetStorageMethodUpdateJob at #{Time.now.to_s} for Asset #{object_key}"    
  end
  
end