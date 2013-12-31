class ReplacementCostPlusInterestCalculator < ReplacementCostCalculator
  
  # average replacement cost (policy year) for the asset plus accrued interest from the policy year until the replacement year
  def calculate(asset)

    Rails.logger.info "ReplacementCostPlusInterestCalculator.calculate(asset)"
    
    # Get the replacement cost of the asset
    initial_cost = super
    Rails.logger.info "initial_cost #{initial_cost}"
    
    # Calculate the replacement year with respect to the policy
    policy_replacement_year = asset.calculate_replacement_year(@policy)
    Rails.logger.info "policy replacement_year #{policy_replacement_year}"

    # if we are past the replacement year, the replacement year is the max of the policy year
    # or now
    replacement_year = [policy_replacement_year, Date.today.year].max
    Rails.logger.info "actual replacement_year #{replacement_year}"
         
    # Do the math...
    num_years_to_replacement = [replacement_year - asset.in_service_date.year, 0].max
    Rails.logger.info "num_years_to_replacement #{num_years_to_replacement}"
    
    future_cost(initial_cost, num_years_to_replacement)
  end
  
end