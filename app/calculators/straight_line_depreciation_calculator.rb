class StraightLineDepreciationCalculator < DepreciationCalculator
  
  # Determines the estimated value for an asset. 
  def calculate(asset)

    # depreciation time
    num_years = asset.asset_subtype.avg_life_years
    
    # calcuate the depreciation       
    annual_depreciation = basis(asset) / num_years.to_f
    age = asset.age
    depreciated_value = purchase_cost(asset) - (annual_depreciation * age)
    # return the max of the residual value and the depreciated value
    [depreciated_value, residual_value(asset)].max
  end
  
end