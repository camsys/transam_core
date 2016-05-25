#------------------------------------------------------------------------------
#
# AssetUpdateJob
#
# Performs all updates on an asset
#
#------------------------------------------------------------------------------
class AssetUpdateJob < AbstractAssetUpdateJob

  def requires_sogr_update?
    true
  end

  # If a generic Asset is passed, we run an incomplete list of update methods
  def execute_job(typed_asset)
    update_methods = typed_asset.update_methods

    # Is SOGR status expensive to update?
    #unless requires_sogr_update?
    #  update_methods.remove(:update_sogr)
    #end

    update_methods.each do |method|
      typed_asset.send(method, false) #dont save until all updates have run
    end
    typed_asset.save
  end

  def prepare
    Rails.logger.debug "Executing AssetUpdateJob at #{Time.now.to_s} for Asset #{object_key}"
  end

end
