require 'delegate'

class AssetDecorator < SimpleDelegator
  def initialize(asset_ids)
    @assets = asset_ids
    super(@assets)
  end

  def whichHierarchy(new = true)
    __setobj__(new ? TransitAsset.where(asset_id: @assets).specific : Asset.unscoped.where(id: @assets))
    new
  end

end