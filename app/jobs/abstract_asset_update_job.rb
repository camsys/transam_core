#------------------------------------------------------------------------------
#
# AbstractAssetUpdateJob
#
# Base class for jobs which perform updates on assets. All update jobs for assets
# should be derived from this class.
#
#------------------------------------------------------------------------------
class AbstractAssetUpdateJob < Job
  
  attr_accessor :object_key

  # Return true if the specific update requris that the SOGR characteristics
  # of the asset need to also be updated.
  def requires_sogr_update?
    false
  end  
  
  # execution phase. all concrete classes should override this
  # method
  #
  def execute_job(a = nil)
    
  end
  #
  # Define the base class run method. This simply loads the asset 
  # checks it was there and then runs the execution logic
  #
  def run    
    asset = Asset.find_by_object_key(object_key)
    if asset
      # Make sure the asset is typed
      a = Asset.get_typed_asset(asset)

      execute_job(a)      
      
    else
      raise RuntimeError, "Can't find Asset with object_key #{object_key}"
    end
  end
  
  def check    
    raise ArgumentError, "object_key can't be blank " if object_key.blank?
  end
  
  def initialize(object_key)
    super
    self.object_key = object_key
  end

end
