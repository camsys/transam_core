class ServiceLifeCalculator < Calculator
  
  protected
  
  # calculate the service life based on the in_service_date plue
  # the avberage asset lie based on the policy
  def by_age(asset)
    asset.in_service_date.year + @policy.get_policy_item(asset).avg_life_years
  end
  
  def by_condition(asset)
    # get the predicted last year of service based on the asset rating
    # and the policy method
    asset.calculate_estimated_replacement_year(@policy)    
  end  
  
end