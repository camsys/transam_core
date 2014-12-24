#------------------------------------------------------------------------------
#
# AssetDispositionService
#
# Contains business logic associated with managing the disposition of assets
#
#
#------------------------------------------------------------------------------
class AssetDispositionService

  # Include the fiscal year mixin
  include FiscalYear

  #------------------------------------------------------------------------------
  #
  # Disposition List
  #
  # returns a list of assets that need to be disposed by FY, type, and subtype
  #
  #------------------------------------------------------------------------------

  def disposition_list(org, fy_year=current_planning_year_year, asset_type_id=nil, asset_subtype_id=nil)

    Rails.logger.debug "AssetDispositionService:  disposition_list()"
    #
    if org.nil?
      Rails.logger.warn "AssetDispositionService:  disposition list: Org ID cannot be null"
      return []
    end

    # Start to set up the query
    conditions  = []
    values      = []

    # Filter for the selected org
    conditions << "organization_id = ?"
    values << org.id

    # Can't already be marked as disposed
    conditions << "disposition_date IS NOT NULL"

    # Scheduled replacement year, defaults to the next planning year unless
    # specified
    conditions << "scheduled_replacement_year = ?"
    values << fy_year

    # Limit by asset type
    unless asset_type_id.nil?
      conditions << "asset_type_id = ?"
      values << asset_type_id
    end

    unless asset_subtype_id.nil?
      conditions << "asset_subtype_id = ?"
      values << asset_subtype_id
    end

    Asset.where(conditions.join(' AND '), *values)
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  #------------------------------------------------------------------------------
  #
  # Private Methods
  #
  #------------------------------------------------------------------------------
  private

end
