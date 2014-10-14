#------------------------------------------------------------------------------
#
# Activity
#
# Represents a business activity that is requried to be completed
#
#------------------------------------------------------------------------------
class Activity < ActiveRecord::Base
  
  # Include the object key mixin
  include TransamObjectKey
  
  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------

  # Every activity has 0 or more orgasnization types that are required to
  # complete them
  belongs_to :organization_type

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
    
  validates :organization_type, :presence => true, :allow_nil => true
  validates :name,              :presence => true
  validates :description,       :presence => true
  validates :schedule,          :presence => true
  validates :due,               :presence => true
  validates :notify,            :presence => true
  validates :warn,              :presence => true
  validates :alert,             :presence => true
  validates :escalate,          :presence => true
  validates :job_name,          :presence => true

  # List of allowable form param hash keys  
  FORM_PARAMS = [
    :organization_type_id,
    :name,
    :description,
    :schedule,
    :due,
    :notify,
    :warn,
    :alert,
    :escalate,
    :job_name,
    :active
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
  # Instance Methods
  #
  #------------------------------------------------------------------------------
  
  def due_datetime
    Chronic.parse(due)
  end
  def to_s
    name
  end
    
  # Returns a reminder job instance that is configured for this activity  
  def job

    job_name.constantize.new({
      :name => name,
      :activity_description => description,
      :due => due,
      :notify => notify,
      :warn => warn,
      :alert => alert,
      :escalate => escalate
      })
    
  end
  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new organization
  def set_defaults
    self.active ||= true
  end    
  
end
      
