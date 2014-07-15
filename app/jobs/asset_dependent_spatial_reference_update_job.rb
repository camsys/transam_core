#------------------------------------------------------------------------------
#
# AssetDependentSpatialReferenceUpdateJob
#
# Updates the derived spatial reference of all assets associated with the input asset
#
#------------------------------------------------------------------------------
class AssetDependentSpatialReferenceUpdateJob < AbstractAssetUpdateJob
  
  def execute_job(asset) 
    
    # Note that if the asset geometry is null, the dependent assets also
    # get their geometry set to null       
    geom = asset.geometry
    count = 0
    assets = Asset.where('location_id = ?', asset.id)
    assets.each do |a|
      a.geometry = geom
      a.save
      count += 1
    end
    Rails.logger.info "Updated #{count} asset locations."    
  end

  def prepare
    Rails.logger.debug "Executing AssetDependentSpatialReferenceUpdateJob at #{Time.now.to_s} for Asset #{object_key}"    
  end
  
end