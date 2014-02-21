class DecliningBalanceDepreciationCalculator < DepreciationCalculator
  
  # Determines the estimated value for an asset. 
  def calculate(asset)

    # depreciation time
    num_years = @policy.get_policy_item(asset).avg_life_years
    
    # calculate the annual depreciation rate. This is double the actual depreciation rate
    depreciation_rate = (1 / num_years.to_f) * 2
    rv = residual_value(asset)
    v  = purchase_cost(asset)
    # calculate the value of the asset at the end of each year
    [0..age].each do |year|
      v -= (v * depreciation_rate)
      # if the value drops below the residual value then the depreciation stops
      break if v < rv
    end
    # return the max of the residual value and the depreciated value
    [v, rv].max
  end
  
end