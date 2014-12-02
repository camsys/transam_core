#------------------------------------------------------------------------------
#
# StraightLineEstimationCalculator
#
#------------------------------------------------------------------------------
class StraightLineEstimationCalculator < ConditionEstimationCalculator

  # Estimates the condition rating of an asset using straight-line depreciation
  # based on
  #
  # 1] a measured rate of change if the asset has one or more condition updates, or
  # 2] the expected rate of change if no updates have been posted against the asset
  #
  # If the asset has mileage reported then the measured rate of change will be the minimum
  # of the condition assement or milege assessment
  #
  def calculate(asset)

    Rails.logger.debug "StraightLineEstimationCalculator.calculate(asset)"

    # get the maximum and minimum rating for a new asset
    max_rating = ConditionType.max_rating  # Usually 5.0 for FTA applicaitons
    min_rating = ConditionType.min_rating  # Usually 1.0 for FTA applications

    # this is the rating that indicates the asset is at the end of its useful life. Usually 2.5 for FTA applications
    condition_threshold = asset.policy.condition_threshold

    # Get what we need from the policy
    policy_item = asset.policy_rule

    # determine the minimum estimated rating, this is the one with the most negative slope
    slopes = calculate_slope(asset, min_rating, max_rating)

    # determine the scale factor to make the mileage in the same interval as condition
    scale_factor = (max_rating - condition_threshold) / policy_item.max_service_life_miles

    min_slope = [slopes[:condition_slope],slopes[:mileage_slope]*scale_factor].min
    est_rating = max_rating + (min_slope * asset.age)
    Rails.logger.debug "est rating = #{est_rating}"
    # make sure we don't go below the minimum. This is possible as the slope can extend infinitely for extreme cases
    [est_rating.round(2), min_rating].max
  end

  # Estimates the last servicable year for the asset based on the last reported condition. If no
  # condition has been reported, the policy year is returned
  # returned in FY
  def last_servicable_year(asset)

    Rails.logger.debug "StraightLineEstimationCalculator.last_servicable_year(asset)"

    # get the maximum and minimum rating for a new asset
    max_rating = ConditionType.max_rating  # Usually 5.0 for FTA applicaitons
    min_rating = ConditionType.min_rating  # Usually 1.0 for FTA applications

    # this is the rating that indicates the asset is at the end of its useful life. Usually 2.5 for FTA applications
    condition_threshold = asset.policy.condition_threshold

    years_policy    = asset.expected_useful_life.nil? ? asset.policy_rule.max_service_life_months / 12.0 : asset.expected_useful_life / 12.0
    years_mileage   = INFINITY
    years_condition = INFINITY

    # Using the slope intercept formula y = mx + b
    #    where m is the slope
    #    b in the y intercept (max_rating)
    # we can solve for x (year) when we know y (condition) by re-arranging to
    # x = (y - b) / m

    slopes = calculate_slope(asset, min_rating, max_rating)
    # condition
    m = slopes[:condition_slope]
    if m.abs.between?(0.00001, 0.99999)
      b = max_rating
      y = condition_threshold
      Rails.logger.debug "y = mx + b => #{y} = #{m}x + #{b}"
      x = (y - b) / m
      Rails.logger.debug "x = (y - b) / m  => #{x} = (#{y} - #{b}) + #{m}"
      # Take care of any rounding errors
      years_condition = (x + 0.1).to_i
    end

    # mileage
    m = slopes[:mileage_slope]
    if m.abs.between?(0.00001, 0.99999)
      b = policy_item.max_service_life_miles
      y = 0
      x = (y - b) / m
      # Take care of any rounding errors
      years_mileage = (x + 0.1).to_i
    end

    # return the last year that the asset is viable
    Rails.logger.debug "years_policy = #{years_policy}, years_mileage = #{years_mileage}, years_condition = #{years_condition}"
    fiscal_year_year_on_date(asset.in_service_date) + [years_policy, years_mileage, years_condition].min
  end

  protected
    def calculate_slope(asset, min_rating, max_rating)
      #
      # We calculate the slope (y2 - y1) / (x2 - x2) where the x axis is the years and the y axis is the rating
      #   point (x1, y1) is the new asset (0 years, max_condition)
      #   point (x2, y2) is the last known data point if we have one or the end of useful life determined by
      #                  the policy if we dont

      # slope should always be negative as an asset's rating lowers over time

      # this is the rating that indicates the asset is at the end of its useful life. Usually 2.5 for FTA applications
      condition_threshold = asset.policy.condition_threshold

      # Get what we need from the policy
      policy_item = asset.policy_rule

      # this is the max number of years for the asset, i.e. the number of years before the asset's rating is expected to
      # reach the condition_threshold value
      years_policy = asset.expected_useful_life.nil? ? asset.policy_rule.max_service_life_months / 12.0 : asset.expected_useful_life / 12.0

      Rails.logger.debug "asset.age=#{asset.age}, threshold=#{condition_threshold}, min_rating=#{min_rating}, max_rating=#{max_rating}"

      # Assets always rated at the max value when they are new
      x1 = 0
      y1 = max_rating

      # we might calculate this later if we have data
      mileage_slope = 0.0

      # If there are no condition updates then just return the policy based
      # estimation
      if asset.condition_updates.empty?
        Rails.logger.debug "No condition updates."
        x2 = years_policy
        y2 = condition_threshold
        Rails.logger.debug "x1=#{x1} y1=#{y1} x2=#{x2} y2=#{y2}"
        condition_slope = slope(x1, y1, x2, y2)
        Rails.logger.debug "Slope = #{condition_slope}."
      else
        # We determine the new slope from the last data point reported
        condition_report = asset.condition_updates.last
        Rails.logger.debug condition_report.inspect

        last_rating   = condition_report.assessed_rating
        last_mileage  = condition_report.current_mileage
        age_at_report = asset.age(condition_report.event_date)

        # Determine the current slope
        x2 = age_at_report
        y2 = last_rating
        Rails.logger.debug "x1=#{x1} y1=#{y1} x2=#{x2} y2=#{y2}"
        condition_slope = slope(x1, y1, x2, y2)
        Rails.logger.debug "Slope = #{condition_slope}."

        # See if we can do a mileage calculation
        if last_mileage && policy_item.max_service_life_miles && age_at_report > 0
          # Here the slope is based on the number of miles remaining. This keeps the
          # slope in the same direction
          y1 = policy_item.max_service_life_miles
          y2 = policy_item.max_service_life_miles - last_mileage
          # get the slope
          mileage_slope = slope(x1, y1, x2, y2)
        end
      end

      return {:condition_slope => condition_slope, :mileage_slope => mileage_slope}

    end

end
