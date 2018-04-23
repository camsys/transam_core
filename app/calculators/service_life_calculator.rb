#------------------------------------------------------------------------------
#
# ServiceLifeCalculator
#
# base class for ServiceLife calculators
#
#------------------------------------------------------------------------------
class ServiceLifeCalculator < Calculator

  protected

  # calculate the service life based on the in_service_date FY plus the minimum
  # espected life of the asset. If the asset has been rehabilitated we factor
  # in any increase in longevity based on the current policy
  def by_age(asset)

    year = fiscal_year_year_on_date(asset.in_service_date) + (asset.expected_useful_life / 12)
    if asset.last_rehabilitation_date.present?
      asset.rehabilitation_updates.each do |evt|
        year += (evt.extended_useful_life_months / 12)
      end
    end
    year

  end

  # Calculate the service life based on the minimum of condition
  # returns in FY
  def by_condition(asset)
    # Iterate over all the condition update events from earliest to latest
    # and find the first year (if any) that the  policy replacement became
    # effective
    events = asset.condition_updates(true)
    condition_threshold = asset.policy_analyzer.get_condition_threshold
    Rails.logger.debug "Found #{events.count} events."
    Rails.logger.debug "Condition threshold = #{condition_threshold}."
    events.each do |event|
      Rails.logger.debug "Event date = #{event.event_date}, Rating = #{event.assessed_rating}."
      if event.assessed_rating <= condition_threshold
        Rails.logger.debug "returning #{fiscal_year_year_on_date(event.event_date)}"
        return fiscal_year_year_on_date(event.event_date)
      end
    end
    # if we didn't find a condition event that would make the policy effective
    # we can simply return the age constraint
    Rails.logger.debug "returning value from policy age"

    last_year_by_age = by_age(asset)

    if last_year_by_age <= current_planning_year_year
      current_planning_year_year + 1
    else
      last_year_by_age
    end
  end

end
