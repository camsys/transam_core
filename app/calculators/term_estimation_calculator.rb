#------------------------------------------------------------------------------
#
# TermEstimationCalculator
#
#------------------------------------------------------------------------------
class TermEstimationCalculator < ConditionEstimationCalculator
  
  # Estimates the condition rating of an asset using approximations of
  # TERM condition decay splines. The condition is only associated with
  # the age of the asset
  #
  def calculate(asset)
    
    Rails.logger.debug "TERMEstimationCalculator.calculate(asset)"
      
    years = asset.age
    
    if asset.asset_type.name == 'Vehicle'
      if years <= 3
        return -1.75 / 3 * years + 5 + 1.75 / 3
      else
        return 3.29886 * Math.exp(-0.0178422 * years)            
      end
    elsif asset.asset_type.name == 'Rail Car'
      if years <= 2.5
        return -3.75 / 5 * years + 5 + 3.75 / 5
      else
        return 4.54794 * Math.exp(-0.0204658 * years)
      end
    elsif asset.asset_type.name == 'Support Facility'
      if years <= 18
        return 5.08593 * Math.exp(-0.0196381 * years)
      elsif years <= 19
        return -2.08 / 5 * years + 11.236
      else
        return 3.48719 * Math.exp(-0.0042457 * years)
      end
    elsif asset.asset_type.name == 'Transit Facility'
      return scaled_sigmoid(6.689 - 0.255 * years)
      
    elsif asset.asset_type.name == 'Fixed Guideway'
      return 4.94961 * Math.exp(-0.0162812 * years)
    
    else
      # If we don't have a term curve then default to a Straight Line Estimation
      slc = StraightLineEstimationCalculator.new(@policy)
      return slc.calculate(asset)
    end
    
  end
  
  # Estimates the last servicable year for the asset based on the TERM Decay curves
  def last_servicable_year(asset)

    Rails.logger.debug "TERMEstimationCalculator.last_servicable_year(asset)"
    #TODO implement this
    # If we don't have a term curve then default to a Straight Line Estimation
    slc = StraightLineEstimationCalculator.new(@policy)
    return slc.last_servicable_year(asset)

  end  
  
  def scaled_sigmoid(val)
    x = Math.exp(val)
    return x / (1.0 + x) * 4 + 1
  end

end