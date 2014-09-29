#------------------------------------------------------------------------------
#
# ReplacementCostCalculator
#
#------------------------------------------------------------------------------
class ReplacementCostCalculator < CostCalculator
  
  # Determines the calculated replacement cost for an asset. 
  def calculate(asset)
  
    # The default behavior is to return the replacement cost of the asset from the schedule
    asset.get_rule.replacement_cost

  end
  
end