# Include the FileSizevalidator mixin
require 'file_size_validator'

class Upload < ActiveRecord::Base

  # From system config
  MAX_UPLOAD_FILE_SIZE = Rails.application.config.max_upload_file_size

  # Include the object key mixin
  include TransamObjectKey

  #-----------------------------------------------------------------------------
  # Callbacks
  #-----------------------------------------------------------------------------
  after_initialize  :set_defaults
  before_destroy    :unassociate_events

  # Associations
  belongs_to :user
  belongs_to :organization
  belongs_to :file_status_type
  belongs_to :file_content_type
  # Asset events can be created by bulk update
  has_many   :asset_events

  # uploader
  mount_uploader :file, ExcelUploader

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

  #-----------------------------------------------------------------------------
  #
  # Class Methods
  #
  #-----------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
  end

  #-----------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #-----------------------------------------------------------------------------

  # Returns the number of seconds needed to process the file
  def processing_time
    if processing_completed_at.present? and processing_started_at.present?
      processing_completed_at - processing_started_at
    end
  end

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

  # Resets the state of the upload and destroys dependent events
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
    asset_events.destroy_all
  end

  protected

  # Set resonable defaults for a new vehicle
  def set_defaults
    self.file_status_type_id ||= FileStatusType.find_by_name('Unprocessed').id
  end

  # Destroying an upload only removes the upload, events remain, but must be unassociated
  def unassociate_events
    asset_events.update_all(upload_id: nil)
  end

end
