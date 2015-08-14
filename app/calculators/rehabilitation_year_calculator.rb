#------------------------------------------------------------------------------
#
# RehabilitationYearCalculator
#
# Returns the year that an asset should be rehabilitated based on the asset
# and the asset's policy
#
#------------------------------------------------------------------------------
class RehabilitationYearCalculator < Calculator

  # Main entry point
  def calculate(asset)

    Rails.logger.debug "RehabilitationYearCalculator.calculate(asset)"
    # The policy rehabilitation year identifies the year of the assets service
    # that a rehabiliation should be performed. If not set, no rehabiliation
    # will be scheduled otherwise find the fiscal year that is x years after the
    # fiscal year the asset was placed in service
    years_into_service = asset.policy_rule.rehabilitation_year
    if years_into_service.to_i > 0
      # return the in service fiscal year plus the policy rehab year
      fiscal_year_year_on_date(asset.in_service_date) + years_into_service
    else
      nil
    end
  end

  protected

end
