class StraightLineEstimationCalculator < ConditionEstimationCalculator
  
  # Estimates the condition rating of an asset using straight-line depreciation
  # based on either a measured rate of change if the asset has one or more 
  # condition updates, or the expected rate of change is no updates have been 
  # posted against the asset
  def calculate(asset)
    
    Rails.logger.info "StraightLineEstimationCalculator.calculate(asset)"
    
    # get the maximum (initial) rating for a new asset
    max_rating = ConditionType.max_rating
  
    # See if we have condition updates
    if asset.condition_updates.empty?

      # Get the minimum accepatable condition from the policy
      rating = @policy.condition_threshold

      # Expected age of the asset in years
      years = asset.asset_subtype.avg_life_years
      
    else
      # we can calculate a new slope by determining the rate of change over the life of the asset
      # based on the last reported condition

      condition_report = asset.condition_updates.first
      rating = condition_report.assessed_rating
      
      # Get the age of the asset when the report was created
      years = asset.age(condition_report.event_date)
        
    end
    # Get the rate of change in asset quality per year
    rate_of_change = rate_of_deterioration_per_year(max_rating, rating, years)
    
    # calculate the expected rating based on the assets age and either the expected or observed
    # rate of cahnge
    rating = max_rating - (rate_of_change * asset.age)
          
  end
  
  # Estimates the last servicable year for the asset based on the last reported condition. If no
  # condition has been reported, the policy year is returned
  def last_servicable_year(asset)

    Rails.logger.info "StraightLineEstimationCalculator.last_servicable_year(asset)"
    
    # Return the policy year if there are no condition updates recorded against the asset
    if asset.condition_updates.empty?
      year = asset.in_service_date.year + asset.asset_subtype.avg_life_years
    else
      # get the maximum (initial) rating for a new asset
      max_rating = ConditionType.max_rating

      condition_report = asset.condition_updates.first
      current_rating = condition_report.assessed_rating
      age_at_report = asset.age(condition_report.event_date)

      # Get the observed rate of change in asset quality
      rate_of_change = rate_of_deterioration_per_year(max_rating, current_rating, age_at_report)
      # determine the year that the service quality will fall below the threshold
      years_at_rate = (max_rating - current_rating) / rate_of_change
      year = asset.in_service_date.year + years_at_rate.to_i
    end
      
  end  

  protected

  # Calculates the linear deterioration in asset quality per year
  def rate_of_deterioration_per_year(max_rating, min_rating, years)

    # Determine the change in condition
    delta = max_rating - min_rating
    
    # Determine the normal rate of change in rating per year
    delta / years
    
  end
  
end