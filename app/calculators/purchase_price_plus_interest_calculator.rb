#------------------------------------------------------------------------------
#
# PurchasePricePlusInterestCalculator
#
# Calculates asset costs base on the initial price of the asset plus compounded
# interest from the in service year to the replacement year
#
#------------------------------------------------------------------------------
class PurchasePricePlusInterestCalculator < CostCalculator

  def calculate(asset)

    Rails.logger.debug "PurchasePricePlusInterestCalculator.calculate(asset)"

    # Get the initial cost of the asset
    initial_cost = asset.cost
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
