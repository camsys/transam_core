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
    
    # Calculate the replacement year with respect to the policy
    policy_replacement_year = asset.calculate_replacement_year(@policy)
    Rails.logger.debug "policy replacement_year #{policy_replacement_year}"

    # if we are past the replacement year, the replacement year is the max of the policy year
    # or now
    replacement_year = [policy_replacement_year, Date.today.year].max
    Rails.logger.debug "actual replacement_year #{replacement_year}"
         
    # Do the math...
    num_years_to_replacement = [replacement_year - asset.in_service_date.year, 0].max
    Rails.logger.debug "num_years_to_replacement #{num_years_to_replacement}"
    
    future_cost(initial_cost, num_years_to_replacement)

  end
  
end