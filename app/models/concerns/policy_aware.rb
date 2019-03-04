module PolicyAware

  extend ActiveSupport::Concern

  included do


    # Before the asset is updated we may need to update things like estimated
    # replacement cost if they updated other things
    # updates the calculated values of an asset
    after_save      :check_policy_rule
    after_save      :update_asset_state

  end

  module ClassMethods
    def self.cleansable_fields
      [
          'policy_replacement_year',
          'scheduled_replacement_year',
          'scheduled_replacement_cost',
          'in_backlog'
      ]
    end
  end

  def policy
    organization.get_policy
  end

  #-----------------------------------------------------------------------------
  # Return the policy analyzer for this asset. If a policy is not provided the
  # default policy for the asset is used
  #-----------------------------------------------------------------------------
  def policy_analyzer(policy_to_use=nil)
    if policy_to_use.blank?
      policy_to_use = policy
    end
    policy_analyzer = Rails.application.config.policy_analyzer.constantize.new(TransamAsset.get_typed_asset(self), policy_to_use)
  end

  def estimated_condition_rating
    # Estimate the year that the asset will need replacing amd the estimated
    # condition of the asset
    begin
      class_name = policy_analyzer.get_condition_estimation_type.class_name
      calculate(TransamAsset.get_typed_asset(self), class_name)
    rescue Exception => e
      Rails.logger.warn e.message
      Rails.logger.error e.backtrace
    end
  end
  def estimated_condition_type
    ConditionType.from_rating(estimated_condition_rating)
  end

  protected

  # updates the calculated values of an asset
  def update_asset_state

    return unless self.replacement_by_policy? || self.replacement_pinned?

    Rails.logger.debug "Updating SOGR for transam asset = #{object_key}"

    if disposed?
      Rails.logger.debug "Asset #{object_key} is disposed"
    end

    # returns the year in which the asset should be replaced based on the policy and asset
    # characteristics
    begin
      # store old policy replacement year for use later
      old_policy_replacement_year = policy_replacement_year

      # see what metric we are using to determine the service life of the asset
      class_name = policy_analyzer.get_service_life_calculation_type.class_name

      new_policy_replacement_year = calculate(TransamAsset.get_typed_asset(self), class_name)
      update_columns(policy_replacement_year: new_policy_replacement_year) if old_policy_replacement_year != new_policy_replacement_year

      if self.scheduled_replacement_year.nil? or self.scheduled_replacement_year == old_policy_replacement_year
        Rails.logger.debug "Setting scheduled replacement year to #{policy_replacement_year}"
        update_columns(scheduled_replacement_year: self.policy_replacement_year, in_backlog: false)
      end
      # If the asset is in backlog set the scheduled year to the current FY year
      if self.scheduled_replacement_year < current_planning_year_year
        Rails.logger.debug "Asset is in backlog. Setting scheduled replacement year to #{current_planning_year_year}"
        update_columns(scheduled_replacement_year: current_planning_year_year, in_backlog: true)
      end
    rescue Exception => e
      Rails.logger.warn e.message
      Rails.logger.warn e.backtrace
    end

    # If the policy replacement year changes we need to check to see if the asset
    # is in backlog and update the scheduled replacement year to the first planning
    # year
    if self.policy_replacement_year < current_planning_year_year
      update_columns(in_backlog: true)
    else
      update_columns(in_backlog: false) if self.in_backlog != false
    end

    Rails.logger.debug "New scheduled_replacement_year = #{self.scheduled_replacement_year}"
    # Get the calculator class from the policy analyzer
    class_name = policy_analyzer.get_replacement_cost_calculation_type.class_name
    calculator_instance = class_name.constantize.new
    start_date = start_of_fiscal_year(scheduled_replacement_year) unless scheduled_replacement_year.blank?
    Rails.logger.debug "Start Date = #{start_date}"
    get_sched_cost = (calculator_instance.calculate_on_date(self, start_date)+0.5).to_i
    update_columns(scheduled_replacement_cost: get_sched_cost) if get_sched_cost != self.scheduled_replacement_cost

    #self.early_replacement_reason = nil if check_early_replacement && !is_early_replacement?
  end

  def check_policy_rule

    policy.find_or_create_asset_type_rule self.asset_subtype.asset_type

    typed_asset = TransamAsset.get_typed_asset self
    if (typed_asset.respond_to? :fuel_type)
      policy.find_or_create_asset_subtype_rule asset_subtype, typed_asset.fuel_type
    else
      policy.find_or_create_asset_subtype_rule asset_subtype
    end
  end

  private

  # Calls a calculate method on a Calculator class to perform a condition or cost calculation
  # for the asset. The method name defaults to x.calculate(asset) but other methods
  # with the same signature can be passed in
  def calculate(asset, class_name, target_method = 'calculate')
    begin
      Rails.logger.debug "#{class_name}, #{target_method}"
      # create an instance of this class and call the method
      calculator_instance = class_name.constantize.new
      Rails.logger.debug "Instance created #{calculator_instance}"
      method_object = calculator_instance.method(target_method)
      Rails.logger.debug "Instance method created #{method_object}"
      method_object.call(asset)
    rescue Exception => e
      Rails.logger.error e.message
      Rails.logger.error e.backtrace
      raise RuntimeError.new "#{class_name} calculation failed for asset #{asset.object_key} and policy #{policy.name}"
    end
  end

end