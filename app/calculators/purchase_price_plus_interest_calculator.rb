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

  def calculate_on_date(asset, on_date=nil)

    Rails.logger.debug "PurchasePricePlusInterestCalculator.calculate(asset)"

    # Get the initial cost of the asset
    initial_cost = asset.cost
    Rails.logger.debug "initial_cost #{initial_cost}"

    purchase_date = asset.purchase_date

    if on_date.nil?
      num_years_to_replacement = [current_planning_year_year - fiscal_year_year_on_date(purchase_date), 0].max
    else
      num_years_to_replacement = [fiscal_year_year_on_date(on_date)- fiscal_year_year_on_date(purchase_date), 0].max
    end
    Rails.logger.debug "num_years_to_replacement #{num_years_to_replacement}"

    # inflation rate as decimal
    inflation_rate = asset.policy_analyzer.get_annual_inflation_rate / 100.0
    cost_in_future = future_cost(initial_cost, num_years_to_replacement, inflation_rate)
    (cost_in_future + 0.5).floor # even rounds up
  end

end
