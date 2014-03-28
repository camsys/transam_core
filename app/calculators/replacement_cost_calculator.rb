#------------------------------------------------------------------------------
#
# ReplacementCostCalculator
#
#------------------------------------------------------------------------------
class ReplacementCostCalculator < CostCalculator
  
  # Determines the calculated replacement cost for an asset. 
  def calculate(asset)
  
    # The default behavior is to return the replacement cost of the asset from the schedule
    @policy.get_policy_item(asset).replacement_cost

  end
  
end