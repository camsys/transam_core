# During a rehabilitation update, subsystems can be selected and associated
# with a cost
class AssetEventAssetSubsystem < ActiveRecord::Base
 #-----------------------------------------------------------------------------
  # Callbacks
  #-----------------------------------------------------------------------------
  after_initialize  :set_defaults

  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  # Every sign_order_sign belongs to a sign
  belongs_to  :rehabilitation_update_event,
                :class_name  => 'RehabilitationUpdateEvent',
                :foreign_key => "asset_event_id",
                :inverse_of  => :asset_event_asset_subsystems

  # Every asset_event_subsystem belongs to a subsystem
  belongs_to  :asset_subsystem

  #-----------------------------------------------------------------------------
  # Scopes
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates     :asset_subsystem,             :presence => true
  validates     :rehabilitation_update_event, :presence => true
  validates     :parts_cost,                  :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}, allow_nil: true
  validates     :labor_cost,                  :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}, allow_nil: true

  #-----------------------------------------------------------------------------
  # Constants
  #-----------------------------------------------------------------------------

  # List of allowable form param hash keys
  FORM_PARAMS = [
    :id,
    :asset_subsystem_id,
    :asset_event_id,
    :parts_cost,
    :labor_cost
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
  def cost
    parts_cost + labor_cost
  end
  #-----------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #-----------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new instance
  def set_defaults

  end
end
