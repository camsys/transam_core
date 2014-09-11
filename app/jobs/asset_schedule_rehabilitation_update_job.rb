#------------------------------------------------------------------------------
#
# AssetScheduleRehabilitationUpdateJob
#
# Updates an assets scheduled rehabilitation year
#
#------------------------------------------------------------------------------
class AssetScheduleRehabilitationUpdateJob < AbstractAssetUpdateJob
  
  # Force an update of the SOGR characteristics based on the new replacement date  
  def requires_sogr_update?  
    true
  end  
  
  def execute_job(asset)       
    asset.update_scheduled_rehabilitation
  end

  def prepare
    Rails.logger.debug "Executing AssetScheduleRehabilitationUpdateJob at #{Time.now.to_s} for Asset #{object_key}"    
  end
 
end