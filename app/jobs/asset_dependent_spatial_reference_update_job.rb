#------------------------------------------------------------------------------
#
# AssetDependentSpatialReferenceUpdateJob
#
# Updates the derived spatial reference of all assets associated with the input asset
#
#------------------------------------------------------------------------------
class AssetDependentSpatialReferenceUpdateJob < Job
  
  attr_accessor :object_key
  
  def run    
    asset = Asset.find_by_object_key(object_key)
    if asset
      geom = asset.geometry
      count = 0
      assets = Asset.where('location_id = ?', asset.id)
      assets.each do |a|
        a.geometry = geom
        a.save
        count += 1
      end
      Rails.logger.info "Updated #{count} asset locations."    
    else
      raise RuntimeError, "Can't find Asset with object_key #{object_key}"
    end
  end

  def prepare
    Rails.logger.debug "Executing AssetDependentSpatialReferenceUpdateJob at #{Time.now.to_s} for Asset #{object_key}"    
  end
  
  def check    
    raise ArgumentError, "object_key can't be blank " if object_key.blank?
  end
  
  def initialize(object_key)
    super
    self.object_key = object_key
  end

end