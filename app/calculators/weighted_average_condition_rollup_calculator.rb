class WeightedAverageConditionRollupCalculator < Calculator
  
  # Calculates the last year for service given the asset sub type and the date the asset was placed
  # into service
  def calculate(asset)

    Rails.logger.debug "WeightedAverageConditionRollupCalculator.calculate(asset)"

    # only assets with a replacement cost really have a weight so can ignore any without
    ratings = asset.dependents.where('scheduled_replacement_cost > 0').pluck(:scheduled_replacement_cost, :reported_condition_rating)
    return nil if ratings.size == 0

    temp_sum = 0
    ratings.each do |rc|
      temp_sum += rc[0] * (rc[1] || 0) # if no reported condition, default to 0 / Unknown
    end

    return (temp_sum/(ratings.sum{|rc| rc[0]})).round # for now round
    
  end
  
end