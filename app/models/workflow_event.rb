#------------------------------------------------------------------------------
#
# WorkflowEvent
#
# A WorkflowEvent that has been associated with another class such as a Workorder, Asset etc. This is a 
# polymorphic class that can store workflow events against any class that includes an
# accountable association
#
# To use this class as an association with another class include the following line into
# the model
#
# has_many    :workflow_events, :as => :accountable, :dependent => :destroy
#
#------------------------------------------------------------------------------
class WorkflowEvent < ActiveRecord::Base

  # Include the unique key mixin
  include UniqueKey

  #------------------------------------------------------------------------------
  # Overrides
  #------------------------------------------------------------------------------
  
  #require rails to use the asset key as the restful parameter. All URLS will be of the form
  # /workflow_event/{object_key}/...
  def to_param
    object_key
  end
      
  # Callbacks
  after_initialize  :set_defaults

  # Always generate a unique asset key before saving to the database
  before_validation(:on => :create) do
    generate_unique_key(:object_key)
  end
            
  # Associations
  belongs_to :accountable,  :polymorphic => true

  belongs_to :creator,    :class_name => 'User', :foreign_key => :created_by_id 
       
  # default scope
  default_scope { order(:created_at) }
       
  validates :object_key,          :presence => true
  validates :event_type,          :presence => true
  validates :creator,             :presence => true

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :object_key,
    :event_type,
    :accountable_id,
    :accountable_type,
    :created_by_id
  ]
  
  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------
    
  def self.allowable_params
    FORM_PARAMS
  end
    
  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new asset event
  def set_defaults

  end    
    
  #------------------------------------------------------------------------------
  #
  # Private Methods
  #
  #------------------------------------------------------------------------------
  private
  
end
