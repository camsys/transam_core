class CustomWeightedConditionRollupCalculator < Calculator
  
  # Calculates the last year for service given the asset sub type and the date the asset was placed
  # into service
  def calculate(asset)

    Rails.logger.debug "CustomWeightedConditionRollupCalculator.calculate(asset)"

    ratings = asset.dependents.where('weight IS NOT NULL').pluck(:weight, :reported_condition_rating)
    return nil if ratings.size == 0

    temp_sum = 0
    ratings.each do |rc|
      temp_sum += rc[0] * (rc[1] || 0) # if no reported condition, default to 0 / Unknown
    end

    return (temp_sum/(ratings.sum{|rc| rc[0]})).round # for now round
    
  end
  
end