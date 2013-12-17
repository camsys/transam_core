class ReplacementCostCalculator < CostCalculator
  
  # Determines the calculated replacement cost for an asset. 
  def calculate(asset)
  
    # Just return the cost from the asset itself. Assumes the replacement cost
    # is the same as the iniital cost
    asset.cost

  end
  
end