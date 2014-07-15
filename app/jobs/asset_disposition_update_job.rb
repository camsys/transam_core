#------------------------------------------------------------------------------
#
# AssetDispositionUpdateJob
#
# Records that an asset has been disposed.
#
#------------------------------------------------------------------------------
class AssetDispositionUpdateJob < AbstractAssetUpdateJob
  
  
  def execute_job(asset)     
    asset.record_disposition
  end

  def prepare
    Rails.logger.debug "Executing AssetDispositionUpdateJob at #{Time.now.to_s} for Asset #{object_key}"    
  end
  
end