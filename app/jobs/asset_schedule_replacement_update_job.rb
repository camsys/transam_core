#------------------------------------------------------------------------------
#
# AssetScheduleReplacementUpdateJob
#
# Updates an assets scheduled replacement/rehabilitation
#
#------------------------------------------------------------------------------
class AssetScheduleReplacementUpdateJob < AbstractAssetUpdateJob
  
  def execute_job(asset)       
    asset.update_scheduled_replacement
  end

  def prepare
    Rails.logger.debug "Executing AssetScheduleReplacementUpdateJob at #{Time.now.to_s} for Asset #{object_key}"    
  end
 
end