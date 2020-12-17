# --------------------------------
# # DEPRECATED see TTPLAT-1832 or https://wiki.camsys.com/pages/viewpage.action?pageId=51183790
# --------------------------------
# #------------------------------------------------------------------------------
#
# AssetScheduleReplacementUpdateJob
#
# Updates an assets scheduled replacement year
#
#------------------------------------------------------------------------------
class AssetScheduleReplacementUpdateJob < AbstractAssetUpdateJob
  
  # Force an update of the SOGR characteristics based on the new replacement date  
  def requires_sogr_update?  
    true
  end  
  
  def execute_job(asset)       
    asset.update_scheduled_replacement
  end

  def prepare
    Rails.logger.debug "Executing AssetScheduleReplacementUpdateJob at #{Time.now.to_s} for Asset #{object_key}"    
  end
 
end