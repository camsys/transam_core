#-------------------------------------------------------------------------------
# InspectionProxy
#
# Proxy class for gathering inspection search parameters
#
#-------------------------------------------------------------------------------
class TransamWorkflowModelProxy < Proxy

  #-----------------------------------------------------------------------------
  # Attributes
  #-----------------------------------------------------------------------------

  attr_accessor   :include_updates
  attr_accessor   :event_name
  attr_accessor   :to_state
  attr_accessor   :global_ids
  attr_accessor   :model_objs

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Constants
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  #
  # Class Methods
  #
  #-----------------------------------------------------------------------------

  def self.allowable_params
    [
        :include_updates,
        :event_name,
        :to_state,
        :global_ids => []
    ]
  end

  #-----------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Returns the search proxy as hash as if a form had been submitted
  #-----------------------------------------------------------------------------
  def to_h
    h = {}
    a = {}
    FORM_PARAMS.each do |param|
      a[param] = self.try(param) unless self.try(param).blank?
    end
    
    h[:transam_workflow_model_proxy] = a
    h.with_indifferent_access
  end

  def class_name
    model_objs.first.class.to_s
  end

  #-----------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #-----------------------------------------------------------------------------
  protected

  def initialize(attrs = {})
    super
    attrs.each do |k, v|
      self.send "#{k}=", v
    end

    self.model_objs = []
    self.global_ids.each do |global_id|
      model_objs << GlobalID::Locator.locate(global_id)
    end

  end

end
