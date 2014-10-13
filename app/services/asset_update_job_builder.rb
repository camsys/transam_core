#------------------------------------------------------------------------------
#
# AssetUpdater
#
# Searches through an organization's assets and creates update jobs
# for each asset in given types.
#
#------------------------------------------------------------------------------
class AssetUpdateJobBuilder
  def build(organization, options)
    num_to_update = 0
    
    # Rip through the organizations assets, creating a job for each type requested
    organization.assets.where(asset_type: options[:asset_type_ids]).each do |asset|
      Delayed::Job.enqueue AssetUpdateJob.new(asset.object_key, true), :priority => 10
      num_to_update += 1
    end
    return num_to_update
  end



  #------------------------------------------------------------------------------
  #
  # Private Methods
  #
  #------------------------------------------------------------------------------
  private
end