class ReplacementCostCalculator < CostCalculator
  
  # Determines the calculated replacement cost for an asset. 
  def calculate(asset)
  
    # The default behavior is to return the calculated cost of the asset
    asset.cost

  end
  
end