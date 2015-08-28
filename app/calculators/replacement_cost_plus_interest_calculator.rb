#------------------------------------------------------------------------------
#
# ReplacementCostPlusInterestCalculator
#
#------------------------------------------------------------------------------
class ReplacementCostPlusInterestCalculator < ReplacementCostCalculator

  def calculate(asset)
    calculate_on_date(asset)
  end

  # average replacement cost for the asset plus accrued interest
  # from the policy year (in FY) until the FY of the given date (the planning year by default)
  def calculate_on_date(asset,on_date=nil)

    Rails.logger.debug "ReplacementCostPlusInterestCalculator.calculate(asset)"

    # Get the replacement cost of the asset
    initial_cost = asset.cost
    Rails.logger.debug "initial_cost #{initial_cost}"

    if on_date.nil?
      replacement_year = current_planning_year_year
    else
      replacement_year = fiscal_year_year_on_date(on_date)
    end
    Rails.logger.debug "actual replacement_year #{replacement_year}"

    # Calculate the number of years to carry the inflation rate
    num_years_to_replacement = [replacement_year - asset.policy_analyzer.get_cost_fy_year, 0].max
    Rails.logger.debug "num_years_to_replacement #{num_years_to_replacement}"

    # interest rate
    inflation_rate = asset.policy_analyzer.get_annual_inflation_rate

    future_cost(initial_cost, num_years_to_replacement, inflation_rate)
  end


end
