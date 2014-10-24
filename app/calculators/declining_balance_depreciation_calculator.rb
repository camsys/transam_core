#------------------------------------------------------------------------------
#
# DecliningBalanceDepreciationCalculator
#
#------------------------------------------------------------------------------
class DecliningBalanceDepreciationCalculator < DepreciationCalculator

  # Determines the estimated value for an asset.
  def calculate(asset)

    # depreciation time
    num_years = asset.policy_rule.max_service_life_years
    # Age of the asset
    asset_age = asset.age
    Rails.logger.debug "Age = #{asset_age}, max service life = #{num_years}"
    # calculate the annual depreciation rate. This is double the actual depreciation rate
    depreciation_rate = (1 / num_years.to_f) * 2
    rv = residual_value(asset)
    v  = purchase_cost(asset)
    Rails.logger.debug "purchase cost = #{v}, residual value = #{rv} depreciation_rate = #{depreciation_rate}"

    if asset_age < 1
      return v
    end

    # calculate the value of the asset at the end of each year
    (1..asset_age).each do |year|
      v -= (v * depreciation_rate)
      Rails.logger.debug "year = #{year}, value = #{v}"
      # if the value drops below the residual value then the depreciation stops
      break if v < rv
    end
    # return the max of the residual value and the depreciated value
    [v, rv].max.to_i
  end

end
