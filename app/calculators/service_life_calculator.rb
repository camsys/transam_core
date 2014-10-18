#------------------------------------------------------------------------------
#
# ServiceLifeCalculator
#
# base class for ServiceLife calculators
#
#------------------------------------------------------------------------------
class ServiceLifeCalculator < Calculator

  protected

  # calculate the service life based on the in_service_date FY plus
  # the average asset life based on the policy
  # age is in relation to in_service_date NOT an asset's date based off its manufacture_year
  # this is used to get the derived field asset.policy_replacement_year
  # returns in FY
  def by_age(asset)
    fiscal_year_year_on_date(asset.in_service_date) + asset.policy_rule.max_service_life_years
  end

  # Calculate the service life based on the minimum of condition
  # returns in FY
  def by_condition(asset)

    # Iterate over all the condition update events from earliest to latest
    # and find the first year (if any) that the  policy replacement became
    # effective
    policy_item = asset.policy_rule
    events = asset.condition_updates(true)
    Rails.logger.debug "Found #{events.count} events."
    Rails.logger.debug "Condition threshold = #{asset.policy.condition_threshold}."
    events.each do |event|
      Rails.logger.debug "Event date = #{event.event_date}, Rating = #{event.assessed_rating}."
      if event.assessed_rating <= asset.policy.condition_threshold
        Rails.logger.debug "returning #{fiscal_year_year_on_date(event.event_date)}"
        return fiscal_year_year_on_date(event.event_date)
      end
    end
    # if we didn't find a condition event that would make the policy effective
    # we can simply return the age constraint
    Rails.logger.debug "returning value from policy age"

    by_age(asset)
  end

end
