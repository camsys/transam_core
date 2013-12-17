class ServiceLifeCalculator < Calculator
  
  protected
  
  def by_age(asset)
    asset.in_service_date.year + asset.asset_subtype.avg_life_years
  end
  
  def by_condition(asset)
    # get the predicted last year of service based on the asset rating
    # and the policy method
    asset.calculate_estimated_replacement_year(@policy)    
  end  
  
end