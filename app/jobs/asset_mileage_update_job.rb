#------------------------------------------------------------------------------
#
# AssetMileageUpdateJob
#
# Updates an assets condition
#
#------------------------------------------------------------------------------
class AssetMileageUpdateJob < AbstractAssetUpdateJob
  
  # Force an update of the SOGR characteristics based on the new mileage  
  def requires_sogr_update?  
    true
  end  
  
  def execute_job(asset) 
    asset.update_mileage
  end

  def prepare
    Rails.logger.debug "Executing AssetMileageUpdateJob at #{Time.now.to_s} for Asset #{object_key}"    
  end
  
end