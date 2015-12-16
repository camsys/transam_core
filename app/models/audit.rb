#-------------------------------------------------------------------------------
# Audit
#
# An object can be audited by an auditor job. The results of the audit are stored
# in this class.
#
# To use this class as an association with another class include the following line into
# the model
#
# has_many    :audits,  :as => :auditable, :dependent => :destroy
#
#-------------------------------------------------------------------------------

class Audit < ActiveRecord::Base

  #-----------------------------------------------------------------------------
  # Callbacks
  #-----------------------------------------------------------------------------
  after_initialize  :set_defaults

  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  # Every audit belongs to another object
  belongs_to :auditable,  :polymorphic => true

  # Each audit belongs to an auditor activity
  belongs_to :activity

  # Each audit belongs to an organizaiton
  belongs_to :organization

  # Each audit has a status type
  belongs_to :audit_status_type

  #-----------------------------------------------------------------------------
  # Scopes
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Constants
  #-----------------------------------------------------------------------------
  # List of hash parameters allowed by the controller. As audits are only created
  # by audit jobs there are no form params needed
  FORM_PARAMS = [
  ]

  #-----------------------------------------------------------------------------
  # Class Methods
  #-----------------------------------------------------------------------------
  def self.allowable_params
    FORM_PARAMS
  end

  #-----------------------------------------------------------------------------
  # Instance Methods
  #-----------------------------------------------------------------------------
  def to_s
    name
  end

  #-----------------------------------------------------------------------------
  # Protected Methods
  #-----------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new asset event
  def set_defaults

  end

  #-----------------------------------------------------------------------------
  # Private Methods
  #-----------------------------------------------------------------------------
  private

end
