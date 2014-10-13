#------------------------------------------------------------------------------
#
# ReplacementCostPlusInterestCalculator
#
#------------------------------------------------------------------------------
class ReplacementCostPlusInterestCalculator < ReplacementCostCalculator

  # average replacement cost (policy year) for the asset plus accrued interest from the policy year until the replacement year
  def calculate(asset)

    Rails.logger.debug "ReplacementCostPlusInterestCalculator.calculate(asset)"

    # Get the replacement cost of the asset
    initial_cost = super
    Rails.logger.debug "initial_cost #{initial_cost}"

    # if we are past the replacement year, the replacement year is the max of the asset replacement year
    # or now
    replacement_year = [replacement_year(asset), Date.today.year].max
    Rails.logger.debug "actual replacement_year #{replacement_year}"

    # Do the math...
    # if past replacement year, return 0
    num_years_to_replacement = [replacement_year - asset.in_service_year, 0].max
    Rails.logger.debug "num_years_to_replacement #{num_years_to_replacement}"

    # interest rate
    interest_rate = asset.policy_rule.interest_rate

    future_cost(initial_cost, num_years_to_replacement, interest_rate)
  end

end
