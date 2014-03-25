class ServiceLifeCalculator < Calculator
  
  protected
  
  # calculate the service life based on the manufacture_year plus
  # the average asset life based on the policy
  def by_age(asset)
    asset.manufacture_year + @policy.get_policy_item(asset).max_service_life_years
  end
  
  def by_condition(asset)
    # get the predicted last year of service based on the asset rating
    # and the policy method
    asset.calculate_estimated_replacement_year(@policy)    
  end  
  
end