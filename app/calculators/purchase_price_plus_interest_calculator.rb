#------------------------------------------------------------------------------
#
# PurchasePricePlusInterestCalculator
#
# Calculates asset costs base on the initial price of the asset plus compounded
# interest from the in service year to the replacement year
#
#------------------------------------------------------------------------------
class PurchasePricePlusInterestCalculator < ReplacementCostCalculator
  
  def calculate(asset)
    
    Rails.logger.debug "PurchasePricePlusInterestCalculator.calculate(asset)"

    # Get the initial cost of the asset by calling the cost calculator
    initial_cost = super
    # Determine which year the asset should be replaced in
    replacement_year = asset.calculate_replacement_year(@policy)
    # do the math...
    num_years_to_replacement = [replacement_year - asset.in_service_year, 0].max
    future_cost(initial_cost, num_years_to_replacement)
  end
  
end