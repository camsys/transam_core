#------------------------------------------------------------------------------
#
# AssetScheduleDispositionUpdateJob
#
# Updates an assets scheduled disposition
#
#------------------------------------------------------------------------------
class AssetScheduleDispositionUpdateJob < AbstractAssetUpdateJob
  
  def execute_job(asset)       
    asset.update_scheduled_disposition
  end

  def prepare
    Rails.logger.debug "Executing AssetScheduleDispositionUpdateJob at #{Time.now.to_s} for Asset #{object_key}"    
  end
  
end