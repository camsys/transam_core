#------------------------------------------------------------------------------
#
# ReplacementCostPlusInterestCalculator
#
#------------------------------------------------------------------------------
class ReplacementCostPlusInterestCalculator < ReplacementCostCalculator

  # average replacement cost (policy year) for the asset plus accrued interest
  # from the policy year (in FY) until the replacement year (in FY)
  def calculate(asset)

    Rails.logger.debug "ReplacementCostPlusInterestCalculator.calculate(asset)"

    # Get the replacement cost of the asset
    initial_cost = super
    Rails.logger.debug "initial_cost #{initial_cost}"

    # default last day of fiscal year
    current_depreciation_date = asset.current_depreciation_date

    # if we are past the replacement year, the replacement year is the max of the asset replacement year
    # or now
    replacement_year = [replacement_year(asset), fiscal_year_year_on_date(Date.today)].max
    Rails.logger.debug "actual replacement_year #{replacement_year}"

    # Do the math...
    # if past replacement year, return 0
    num_years_to_replacement = [replacement_year - fiscal_year_year_on_date(asset.depreciation_start_date), 0].max
    Rails.logger.debug "num_years_to_replacement #{num_years_to_replacement}"

    # interest rate
    interest_rate = asset.policy_rule.interest_rate

    future_cost(initial_cost, num_years_to_replacement, interest_rate)
  end

end
