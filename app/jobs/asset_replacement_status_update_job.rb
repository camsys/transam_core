#------------------------------------------------------------------------------
#
# AssetScheduleReplacementUpdateJob
#
# Updates an assets scheduled replacement year
#
#------------------------------------------------------------------------------
class AssetReplacementStatusUpdateJob < AbstractAssetUpdateJob
  
  # Force an update of the SOGR characteristics based on the new replacement date  
  def requires_sogr_update?  
    true
  end  
  
  def execute_job(asset)       
    asset.update_replacement_status
  end

  def prepare
    Rails.logger.debug "Executing AssetReplacementStatusUpdateJob at #{Time.now.to_s} for Asset #{object_key}"
  end
 
end