#------------------------------------------------------------------------------
#
# Notice
#
# Represents a business activity that is requried to be completed
#
#------------------------------------------------------------------------------
class Notice < ActiveRecord::Base
  
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
    
  validates :organization_type, :presence => true
  validates :subject,           :presence => true
  validates :details,           :presence => true
  validates :display_icon_name, :presence => true
  validates :display_datetime,  :presence => true
  validates :end_datetime,      :presence => true
  validates :event_datetime,    :presence => true

  # List of allowable form param hash keys  
  FORM_PARAMS = [
    :organization_type_id,
    :subject,
    :details,
    :display_icon_name,
    :display_datetime,
    :end_datetime,
    :event_datetime,
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
        
  def to_s
    subject
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
      
