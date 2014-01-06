class Upload < ActiveRecord::Base
  
  # Include the unique key mixin
  include UniqueKey

  #------------------------------------------------------------------------------
  # Overrides
  #------------------------------------------------------------------------------
  
  #require rails to use the object  key as the restful parameter. All URLS will be of the form
  # /upload/{object_key}/...
  def to_param
    object_key
  end
  
  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults

  # Always generate a unique asset key before saving to the database
  before_validation(:on => :create) do
    generate_unique_key(:object_key)
  end
    
  # Associations
  belongs_to :user
  belongs_to :customer
  belongs_to :file_status_type
  belongs_to :file_content_type
  
  # uploader
  mount_uploader :file, ExcelUploader      

  #attr_accessible :customer_id, :user_id, :file_content_type_id, :file_status_type_id, :file, :original_filename  
    
  validates       :object_key,        :presence => true, :uniqueness => true
  validates :customer_id, :presence => true
  validates :user_id, :presence => true
  validates :file_status_type_id, :presence => true
  validates :file_content_type_id, :presence => true
  validates :file, :presence => true
  validates :original_filename, :presence => true

  # default scope
  default_scope order('created_at DESC')
  scope :new_files, -> { where('file_status_type_id = ?', FileStatusType.find_by_name('Unprocessed').id) }
  
  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :object_key,
    :customer_id, 
    :user_id, 
    :file_status_type_id, 
    :file_content_type_id,
    :file,
    :original_filename
  ]
  
  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------
    
  def self.allowable_params
    FORM_PARAMS
  end
  
  protected

  # Set resonable defaults for a new vehicle
  def set_defaults
    self.file_status_type_id ||= FileStatusType.find_by_name('Unprocessed').id
  end    
      
end

