#------------------------------------------------------------------------------
#
# ServiceLifeAgeOr`Condition
#
#------------------------------------------------------------------------------
class ServiceLifeAgeOrCondition < ServiceLifeCalculator

  # Calculates the last year for service based on the minimum of the average asset
  # service life or the condition
  def calculate(asset)

    Rails.logger.debug "ServiceLifeAgeAndCondition.calculate(asset)"

    # get the expected last year of service based on age
    last_year_by_age = by_age(asset)

    # get the predicted last year of service based on the asset condition
    last_year_by_condition = by_condition(asset)

    # return the minimum of the two
    [last_year_by_age, last_year_by_condition].min
  end

end
