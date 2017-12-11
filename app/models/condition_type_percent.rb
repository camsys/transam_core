class ConditionTypePercent < ActiveRecord::Base

  #-----------------------------------------------------------------------------
  # Callbacks
  #-----------------------------------------------------------------------------
  after_initialize  :set_defaults

  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  # Every sign_order_sign belongs to a sign
  belongs_to  :condition_update_event,
              :class_name  => 'ConditionUpdateEvent',
              :foreign_key => "asset_event_id",
              :inverse_of  => :condition_type_percents

  # Every asset_event_subsystem belongs to a subsystem
  belongs_to  :condition_type

  #-----------------------------------------------------------------------------
  # Scopes
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates     :condition_type,              :presence => true
  validates     :condition_update_event,      :presence => true
  validates     :pcnt,                        :numericality => {:only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100}, allow_nil: true

  #-----------------------------------------------------------------------------
  # Constants
  #-----------------------------------------------------------------------------

  # List of allowable form param hash keys
  FORM_PARAMS = [
      :id,
      :condition_type_id,
      :asset_event_id,
      :pcnt
  ]

  #-----------------------------------------------------------------------------
  #
  # Class Methods
  #
  #-----------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
  end

  #-----------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #-----------------------------------------------------------------------------


  #-----------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #-----------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new instance
  def set_defaults
    self.pcnt ||= 0
  end
end
