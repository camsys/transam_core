#------------------------------------------------------------------------------
#
# Base class for calculating asset costs
#
#------------------------------------------------------------------------------
class CostCalculator < Calculator

  protected

  # Returns the replacement year for the asset. This is either the schedule_replacement_year if set
  # or the policy_replacement_year otherwise
  # replacement year is in FY
  def replacement_year(asset)
    asset.scheduled_replacement_year.blank? ? asset.policy_replacement_year : asset.scheduled_replacement_year
  end

  # future cost calculation. calculates cost plus compounded interest over the number of years
  def future_cost(initial_cost, number_of_years, interest_rate)
    initial_cost * (1 + interest_rate) ** number_of_years
  end

end
