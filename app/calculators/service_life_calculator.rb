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
  
  # Calculate the service life based on the minimum of condition, or miles if the
  # asset has a maximum number of miles set
  def by_condition(asset)

    # Iterate over all the condition update events from earliest to latest
    # and find the first year (if any) that the  policy replacement became
    # effective
    asset.condition_updates.each do |event|
      if event.assessed_rating < @policy.condition_threshold
        return event.event_date.year
      end
      if event.current_mileage && policy_item.max_service_life_miles
        if event.current_mileage >= policy_item.max_service_life_miles
          return event.event_date.year
        end
      end
    end
    # if we didn't find a condition event that would make the policy effective
    # we can simply return the age constraint
    by_age(asset)
  end  
  
end