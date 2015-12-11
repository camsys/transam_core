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

    return 0 if options.blank?  # Shortcut out if they pass a blank

    # Otherwise, dynamically build a query, based on options
    if options[:asset_type_ids].present?
      asset_type_ids = []
      options[:asset_type_ids].each do |x|
        asset_type_ids << x if x.to_i > 0
      end
    end

    org_assets = organization.assets
    unless asset_type_ids.empty?
      org_assets = org_assets.where(asset_type: asset_type_ids)
    end

    # Rip through the organizations assets, creating a job for each type requested
    org_assets.each {|x| x.update_sogr; x.update_estimated_replacement_cost; x.update_scheduled_replacement_cost}
    org_assets.count
  end



  #------------------------------------------------------------------------------
  #
  # Private Methods
  #
  #------------------------------------------------------------------------------
  private
end
