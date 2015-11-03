#------------------------------------------------------------------------------
#
# AssetMaintenanceUpdateJob
#
# Records an assets maintenance event
#
#------------------------------------------------------------------------------
class AssetMaintenanceUpdateJob < AbstractAssetUpdateJob

  # Force an update of the SOGR characteristics based on the new mileage
  def requires_sogr_update?
    false
  end

  def execute_job(asset)
    asset.update_maintenance
  end

  def prepare
    Rails.logger.debug "Executing AssetMaintenanceUpdateJob at #{Time.now.to_s} for Asset #{object_key}"
  end

end
