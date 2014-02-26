class ServiceLifeAgeOnly < ServiceLifeCalculator
  
  # Calculates the last year for service given the asset sub type and the date the asset was placed
  # into service
  def calculate(asset)

    Rails.logger.debug "ServiceLifeAgeOnly.calculate(asset)"
    
    by_age(asset)
    
  end
  
end