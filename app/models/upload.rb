# Include the FileSizevalidator mixin
require 'file_size_validator' 

class Upload < ActiveRecord::Base
  
  # From system config
  MAX_UPLOAD_FILE_SIZE = Rails.application.config.max_upload_file_size
  
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
  belongs_to :organization
  belongs_to :file_status_type
  belongs_to :file_content_type
  
  # uploader
  mount_uploader :file, ExcelUploader      
    
  validates :object_key,            :presence => true, :uniqueness => true
  validates :organization_id,       :presence => true
  validates :user_id,               :presence => true
  validates :file_status_type_id,   :presence => true
  validates :file_content_type_id,  :presence => true
  validates :file,                  :presence => true, :file_size => { :maximum => MAX_UPLOAD_FILE_SIZE.megabytes.to_i }
  validates :original_filename,     :presence => true
   
  # default scope
  default_scope { order('created_at DESC') }
  scope :new_files, -> { where('file_status_type_id = ?', FileStatusType.find_by_name('Unprocessed').id) }
  
  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :object_key,
    :organization_id, 
    :user_id, 
    :file_status_type_id, 
    :file_content_type_id,
    :file,
    :original_filename,
    :force_update,
    :num_rows_processed,
    :num_rows_added,
    :num_rows_replaced,
    :num_rows_failed,
    :processing_log,
    :processing_completed_at,
    :processing_started_at
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
  def can_resubmit?
    return false if new_record?
    return false if file_status_type_id < 3
    return true
  end
  def can_delete?
    return false if new_record?
    return false if file_status_type_id < 3
    return true
  end
  
  # Resets the state of the upload
  def reset
    self.file_status_type_id = FileStatusType.find_by_name('Unprocessed').id  
    self.num_rows_processed = nil
    self.num_rows_added = nil
    self.num_rows_replaced = nil
    self.num_rows_failed = nil
    self.num_rows_skipped = nil
    self.processing_log = nil
    self.processing_completed_at = nil
    self.processing_started_at = nil
  end
  
  protected

  # Set resonable defaults for a new vehicle
  def set_defaults
    self.file_status_type_id ||= FileStatusType.find_by_name('Unprocessed').id
  end    
      
end

