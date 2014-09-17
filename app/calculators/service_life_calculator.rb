#------------------------------------------------------------------------------
#
# ServiceLifeCalculator
#
# base class for ServiceLife calculators
#
#------------------------------------------------------------------------------
class ServiceLifeCalculator < Calculator
  
  protected
  
  # calculate the service life based on the manufacture_year plus
  # the average asset life based on the policy
  def by_age(asset)
    asset.manufacture_year + @policy.get_policy_item(asset).max_service_life_years
  end
  
  # Calculate the service life based on the minimum of condition
  def by_condition(asset)

    # Iterate over all the condition update events from earliest to latest
    # and find the first year (if any) that the  policy replacement became
    # effective
    policy_item = @policy.get_policy_item(asset)
    events = asset.condition_updates(true)
    Rails.logger.debug "Found #{events.count} events."
    Rails.logger.debug "Condition threshold = #{@policy.condition_threshold}."
    events.each do |event|
      Rails.logger.debug "Event date = #{event.event_date}, Rating = #{event.assessed_rating}."
      if event.assessed_rating <= @policy.condition_threshold
        Rails.logger.debug "returning #{event.event_date.year}"
        return event.event_date.year
      end
    end
    # if we didn't find a condition event that would make the policy effective
    # we can simply return the age constraint
    Rails.logger.debug "returning value from policy age"

    by_age(asset)
  end  
  
end