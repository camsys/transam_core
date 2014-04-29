#------------------------------------------------------------------------------
#
# Document
#
# A document that has been associated with another class such as an Asset etc. This is a 
# polymorphic class that can store documents against any class that includes a
# documentable association
#
# To use this class as an association with another class include the following line into
# the model
#
# has_many    :documents,  :as => :documentable
#
#------------------------------------------------------------------------------

# Include the FileSizevalidator mixin
require 'file_size_validator' 

class Document < ActiveRecord::Base

  # From system config. This is the maximum document size that can be uploaded
  MAX_UPLOAD_FILE_SIZE = Rails.application.config.max_upload_file_size

  # Include the unique key mixin
  include UniqueKey
  
  # Use the carrierway uploader
  mount_uploader :document,   DocumentUploader      

  #------------------------------------------------------------------------------
  # Overrides
  #------------------------------------------------------------------------------
  
  #require rails to use the asset key as the restful parameter. All URLS will be of the form
  # /asset_event/{object_key}/...
  def to_param
    object_key
  end
      
  # Callbacks
  after_initialize  :set_defaults
  before_save       :update_file_attributes  

  # Always generate a unique asset key before saving to the database
  before_validation(:on => :create) do
    generate_unique_key(:object_key)
  end
            
  # Associations
  belongs_to :documentable,  :polymorphic => true
  
  # Each comment was created by a user
  belongs_to :creator, :class_name => "User", :foreign_key => "created_by_id"

  validates :name,                :presence => true
  validates :description,         :presence => true
  validates :original_filename,   :presence => true
  validates :document,            :presence => true, :file_size => { :maximum => MAX_UPLOAD_FILE_SIZE.megabytes.to_i }  
  validates :created_by_id,       :presence => true

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :object_key,
    :documentable_id,
    :documentable_type,
    :document, 
    :name, 
    :description,
    :original_filename,
    :content_type,
    :file_size,
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
  
  def update_file_attributes
    
    if document.present? && document_changed?
      self.content_type = document.file.content_type
      self.file_size = document.file.size
    end
  end
  
end
