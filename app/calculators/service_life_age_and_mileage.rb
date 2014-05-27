#------------------------------------------------------------------------------
#
# ServiceLifeAgeAndMileage
#
#------------------------------------------------------------------------------
class ServiceLifeAgeAndMileage < ServiceLifeCalculator
  
  # Calculates the last year for service based on the minimum of the average asset
  # service life or the condition
  def calculate(asset)

    Rails.logger.debug "ServiceLifeAgeAndMileage.calculate(asset)"

    # get the expected last year of service based on age
    last_year_by_age = by_age(asset)

    # get the predicted last year of service based on the asset mileage
    if asset.type_of? :vehicle
      last_year_by_mileage = by_mileage(asset)
    else
      last_year_by_mileage = 9999
    end
    
    # return the minimum of the two
    [last_year_by_age, last_year_by_mileage].min
  end
  
end