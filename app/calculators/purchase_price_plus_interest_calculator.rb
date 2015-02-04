#------------------------------------------------------------------------------
#
# PurchasePricePlusInterestCalculator
#
# Calculates asset costs base on the initial price of the asset plus compounded
# interest from the in service year (in FY) to the replacement year (in FY)
#
#------------------------------------------------------------------------------
class PurchasePricePlusInterestCalculator < CostCalculator

  def calculate(asset)
    calculate_on_date(asset)
  end

  def calculate_on_date(asset,on_date=nil)

    Rails.logger.debug "PurchasePricePlusInterestCalculator.calculate(asset)"

    # Get the initial cost of the asset
    initial_cost = asset.cost
    Rails.logger.debug "initial_cost #{initial_cost}"

    purchase_date = asset.purchase_date

    if on_date.nil?
      num_years_to_replacement = [current_planning_year_year - fiscal_year_year_on_date(purchase_date), 0].max
    else
      months_to_replacement = (on_date.year * 12 + on_date.month) - (purchase_date.year * 12 + purchase_date.month)
      num_years_to_replacement = [(months_to_replacement.to_f/12.0+0.5).floor, 0].max
    end
    Rails.logger.debug "num_years_to_replacement #{num_years_to_replacement}"

    # interest rate
    interest_rate = asset.policy_rule.policy.interest_rate
    cost_in_future = future_cost(initial_cost, num_years_to_replacement, interest_rate)
    (cost_in_future + 0.5).floor # even rounds up
  end

end
