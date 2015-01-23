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
    if options[:asset_type_ids].present?
      asset_type_ids = []
      options[:asset_type_ids].each do |x|
        asset_type_ids << x if x.to_i > 0
      end
    end
    if options[:asset_group_ids].present?
      asset_group_ids = []
      options[:asset_group_ids].each do |x|
        asset_group_ids << x if x.to_i > 0
      end
    end

    org_assets = organization.assets
    unless asset_type_ids.empty?
      org_assets = org_assets.where(asset_type: asset_type_ids)
    end
    unless asset_group_ids.empty?
      org_assets = org_assets.joins(:asset_groups).where(:asset_groups => {:id => asset_group_ids})
    end
    # Rip through the organizations assets, creating a job for each type requested
    org_assets.pluck(:object_key).each do |object_key|
      Delayed::Job.enqueue AssetUpdateJob.new(object_key), :priority => 10
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
