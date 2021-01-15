
# --------------------------------
# # DEPRECATED see TTPLAT-1832 or https://wiki.camsys.com/pages/viewpage.action?pageId=51183790
# --------------------------------
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