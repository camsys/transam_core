#------------------------------------------------------------------------------
#
# AssetUpdateJobBuilder
#
# Searches through an organization's assets and creates update jobs
# for each asset in given types.
#
#------------------------------------------------------------------------------
class AssetUpdateJobBuilder
  def build(organization, options)
    num_to_update = 0
    return 0 if options.blank?  # Shortcut out if they pass a blank

    # Otherwise, dynamically build a query, based on options
    org_assets = organization.assets
    if options[:asset_type_ids]
      org_assets = org_assets.where(asset_type: options[:asset_type_ids])
    end
    if options[:asset_group_ids]
      org_assets = org_assets.joins(:asset_groups).where(:asset_groups => {:id => options[:asset_group_ids]})
    end

    # Rip through the organizations assets, creating a job for each type requested
    org_assets.each do |asset|
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
