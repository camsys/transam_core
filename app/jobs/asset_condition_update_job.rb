#------------------------------------------------------------------------------
#
# AssetConditionUpdateJob
#
# Updates an assets condition and disposition
#
#------------------------------------------------------------------------------
class AssetConditionUpdateJob < Job
  
  attr_accessor :object_key
  
  def run_job    
    asset = Asset.find_by_object_key(object_key)
    if asset
      asset.update_condition_and_disposition
    else
      raise RuntimeError, "Can't find Asset with object_key #{object_key}"
    end
  end

  def prepare
    Rails.logger.info "Executing AssetConditionUpdateJob at #{Time.now.to_s} for Asset #{object_key}"    
  end
  
  def check    
    raise ArgumentError, "object_key can't be blank " if object_key.blank?
  end
  
  def initialize(object_key)
    super
    self.object_key = object_key
  end

end