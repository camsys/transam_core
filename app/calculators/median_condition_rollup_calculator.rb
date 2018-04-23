class MedianConditionRollupCalculator < Calculator
  
  # Calculates the last year for service given the asset sub type and the date the asset was placed
  # into service
  def calculate(asset)

    Rails.logger.debug "MedianConditionRollupCalculator.calculate(asset)"

    ratings = asset.dependents.pluck(:reported_condition_rating)
    return nil if ratings.size == 0

    tmp = ratings.sort
    mid = (tmp.size / 2).to_i
    return tmp[mid]
    
  end
  
end