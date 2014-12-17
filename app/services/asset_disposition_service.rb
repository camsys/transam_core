#------------------------------------------------------------------------------
#
# AssetService
#
#
#
#------------------------------------------------------------------------------
class AssetDispositionService

  #------------------------------------------------------------------------------
  #
  # Disposition List
  #
  # returns a list of assets that need to be disposed by FY, type, and subtype
  #
  #------------------------------------------------------------------------------

  def disposition_list(fiscal_year=nil, asset_type_id=nil, asset_subtype_id=nil)
    # Start to set up the query
    conditions  = []
    values      = []

    conditions << "disposition_date IS NOT NULL"

    if fiscal_year.nil?
      conditions << "scheduled_replacement_year >= ?"
      values << current_fiscal_year_year
    else
      conditions << "scheduled_replacement_year = ?"
      values << fiscal_year
    end

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
