#------------------------------------------------------------------------------
#
# AssetEstimatedReplacementUpdateJob
#
# Updates an assets estimated replacement cost
#
#------------------------------------------------------------------------------
class AssetEstimatedReplacementUpdateJob < AbstractAssetUpdateJob

  def execute_job(asset)
    asset.update_estimated_replacement_cost
  end

  def prepare
    Rails.logger.debug "Executing AssetEstimatedReplacementUpdateJob at #{Time.now.to_s} for Asset #{object_key}"
  end

end
