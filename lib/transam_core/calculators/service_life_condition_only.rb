class ServiceLifeConditionOnly < ServiceLifeCalculator
  
  # Calculates the last year for service based on the condition of the asset
  def calculate(asset)

    Rails.logger.info "ServiceLifeConditionOnly.calculate(asset)"

    by_condition(asset)    
  end
  
end