class Attachment < ActiveRecord::Base

  # From system config
  MAX_UPLOAD_FILE_SIZE = Rails.application.config.max_upload_file_size
  
  # Include the unique key mixin
  include UniqueKey
  # Include the FileSizevalidator mixin
  include FileSizeValidator

  # uploader
  mount_uploader :image,      ImageUploader      
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
  belongs_to :asset
  belongs_to :attachment_type
  belongs_to :creator, :class_name => "User", :foreign_key => "created_by_id"
  
  validates :object_key,          :presence => true, :uniqueness => true
  validates :asset_id,            :presence => true
  validates :attachment_type_id,  :presence => true
  validates :name,                :presence => true
  validates :original_filename,   :presence => true
  validates :image,               :presence => true, :file_size => { :maximum => MAX_UPLOAD_FILE_SIZE.megabytes.to_i }
  
  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :object_key,
    :asset_id,
    :attachment_type_id, 
    :image,
    :document, 
    :name, 
    :notes,
    :original_filename,
    :content_type,
    :file_size
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
    
    if image.present? && image_changed?
      self.content_type = image.file.content_type
      self.file_size = image.file.size
    end
    if document.present? && document_changed?
      self.content_type = document.file.content_type
      self.file_size = document.file.size
    end
  end

end
