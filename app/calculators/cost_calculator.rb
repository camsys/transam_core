#------------------------------------------------------------------------------
#
# Base class for calculating asset costs
#
#------------------------------------------------------------------------------
class CostCalculator < Calculator
    
  protected

  # future cost calculation. calculates cost plus compounded interest over the number of years
  def future_cost(initial_cost, number_of_years)
    initial_cost * (1 + @policy.interest_rate) ** number_of_years
  end
  
end