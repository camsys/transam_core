class Attachment < ActiveRecord::Base

  # Include the unique key mixin
  include UniqueKey

  # uploader
  mount_uploader :file, AttachmentUploader      

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
  
  validates :object_key,          :presence => true, :uniqueness => true
  validates :asset_id,            :presence => true
  validates :attachment_type_id,  :presence => true
  validates :name,                :presence => true
  validates :original_filename,   :presence => true
  #validates :content_type, :presence => true
  #validates :file_size, :presence => true

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :object_key,
    :asset_id,
    :attachment_type_id, 
    :file, 
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
    
    if file.present? && file_changed?
      self.content_type = file.file.content_type
      self.file_size = file.file.size
    end
  end

end
