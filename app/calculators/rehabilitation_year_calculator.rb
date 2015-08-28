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
    # The policy rehabilitation month identifies the month of the assets service
    # that a rehabiliation should be performed. If not set, no rehabiliation
    # will be scheduled otherwise find the fiscal year that is x months after the
    # fiscal year the asset was placed in service
    months_into_service = asset.policy_analyzer.rehabilitation_service_month
    if months_into_service.to_i > 0
      # return the in service fiscal year plus the policy rehab year
      fiscal_year_year_on_date(asset.in_service_date) + (months_into_service / 12)
    else
      nil
    end
  end

  protected

end
