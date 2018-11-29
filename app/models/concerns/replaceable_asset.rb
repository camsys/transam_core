#
#
# mixin for dispositions, early disposition requests, policy replacement, rehab, and expected useful life
#
#
#


module ReplaceableAsset

  extend ActiveSupport::Concern

  included do

    #---------------------------------------------------------------------------
    # Associations
    #---------------------------------------------------------------------------

    # each asset has zero or more scheduled replacement updates
    has_many   :schedule_replacement_updates, -> {where :asset_event_type_id => ScheduleReplacementUpdateEvent.asset_event_type.id }, :class_name => "ScheduleReplacementUpdateEvent", :as => :transam_asset

    # each asset has zero or more scheduled rehabilitation updates
    has_many   :schedule_rehabilitation_updates, -> {where :asset_event_type_id => ScheduleRehabilitationUpdateEvent.asset_event_type.id }, :class_name => "ScheduleRehabilitationUpdateEvent", :as => :transam_asset

    # each asset has zero or more recorded rehabilitation events
    has_many   :rehabilitation_updates, -> {where :asset_event_type_id => RehabilitationUpdateEvent.asset_event_type.id}, :class_name => "RehabilitationUpdateEvent", :as => :transam_asset
    accepts_nested_attributes_for :rehabilitation_updates, :reject_if => Proc.new{|ae| ae['total_cost'].blank? }, :allow_destroy => true

    # each asset has zero or more scheduled disposition updates
    has_many   :schedule_disposition_updates, -> {where :asset_event_type_id => ScheduleDispositionUpdateEvent.asset_event_type.id }, :class_name => "ScheduleDispositionUpdateEvent", :as => :transam_asset

    # each asset has zero or more disposition updates
    has_many   :disposition_updates, -> {where :asset_event_type_id => DispositionUpdateEvent.asset_event_type.id }, :class_name => "DispositionUpdateEvent", :as => :transam_asset

    # each asset has zero or more early disposition requests
    has_many   :early_disposition_requests, -> {where :asset_event_type_id => EarlyDispositionRequestUpdateEvent.asset_event_type.id }, :class_name => "EarlyDispositionRequestUpdateEvent", :as => :transam_asset

    #---------------------------------------------------------------------------
    # Validations
    #---------------------------------------------------------------------------

    #---------------------------------------------------------------------------
    # Scopes
    #---------------------------------------------------------------------------

    # Returns a list of assets that have been disposed
    scope :disposed,    -> { where.not(disposition_date: nil) }

    # Returns a list of assets that are still operational
    scope :operational, -> { where(TransamAsset.arel_table[:asset_tag].not_eq(TransamAsset.arel_table[:object_key])).where(disposition_date: nil) }

    # Returns a list of asset that in early replacement
    scope :early_replacement, -> { where('policy_replacement_year is not NULL and scheduled_replacement_year is not NULL and scheduled_replacement_year < policy_replacement_year') }

  end

  module ClassMethods
    def self.allowable_params
      [
          {rehabilitation_updates_attributes: RehabilitationUpdateEvent.allowable_params}
      ]
    end

    def self.cleansable_fields
      [
          'disposition_date',
          'early_replacement_reason',
          'scheduled_rehabilitation_year',
          'scheduled_disposition_year'
      ]
    end
  end




  def disposed?
    disposition_date.present?
  end

  # Returns true if the asset can be disposed in the next planning cycle,
  # false otherwise
  def disposable?( include_early_disposal_request_approved_via_transfer = false)
    return false if disposed?
    # otherwise check the policy year and see if it is less than or equal to
    # the current planning year
    return false if policy_replacement_year.blank?

    if policy_replacement_year <= current_planning_year_year
      # After ESL disposal
      true
    else
      # Prior ESL disposal request
      last_request = early_disposition_requests.last
      if include_early_disposal_request_approved_via_transfer
        last_request.try(:is_approved?)
      else
        last_request.try(:is_unconditional_approved?)
      end
    end
  end

  # Returns true if the asset can be requested for early disposal
  def eligible_for_early_disposition_request?
    return false if disposed?
    # otherwise check the policy year and see if it is less than or equal to
    # the current planning year
    return false if policy_replacement_year.blank?

    if policy_replacement_year <= current_planning_year_year
      # Eligible for after ESL disposal
      false
    else
      # Prior ESL disposal request
      last_request = early_disposition_requests.last
      # No previous request or was rejected
      !last_request || last_request.try(:is_rejected?)
    end
  end

  def expected_useful_life
    purchased_new ? policy_analyzer.get_min_service_life_months : policy_analyzer.get_min_used_purchase_service_life_months
  end

  def policy_rehabilitation_year
    # Check for rehabilitation policy events
    begin
      # Use the calculator to calculate the policy rehabilitation fiscal year
      calculator = RehabilitationYearCalculator.new
      return calculator.calculate(TransamAsset.get_typed_asset(self))
    rescue Exception => e
      Rails.logger.warn e.message
      Rails.logger.error e.backtrace
    end
  end

  def estimated_replacement_year
    # Estimate the year that the asset will need replacing
    begin
      class_name = policy_analyzer.get_condition_estimation_type.class_name
      calculate(TransamAsset.get_typed_asset(self), class_name, 'last_servicable_year') + 1
    rescue Exception => e
      Rails.logger.warn e.message
      Rails.logger.error e.backtrace
    end
  end

  def estimated_replacement_cost
    if self.policy_replacement_year < current_planning_year_year
      start_date = start_of_fiscal_year(scheduled_replacement_year)
    else
      start_date = start_of_fiscal_year(policy_replacement_year)
    end
    # Update the estimated replacement costs
    class_name = policy_analyzer.get_replacement_cost_calculation_type.class_name
    calculator_instance = class_name.constantize.new
    (calculator_instance.calculate_on_date(self, start_date)+0.5).to_i
  end

  # Returns true if an asset is scheduled for disposition
  def scheduled_for_disposition?
    (scheduled_disposition_year.present? and disposed? == false)
  end

  def is_early_replacement?
    policy_replacement_year && scheduled_replacement_year && scheduled_replacement_year < policy_replacement_year
  end

  def update_early_replacement_reason(reason = nil)
    if is_early_replacement?
      self.early_replacement_reason = reason
    else
      self.early_replacement_reason = nil
    end
  end

  def formatted_early_replacement_reason
    if early_replacement_reason.present?
      early_replacement_reason
    else
      '(Reason not provided)'
    end
  end

  def last_rehabilitation_date
    rehabilitation_updates.last.try(:event_date)
  end


end