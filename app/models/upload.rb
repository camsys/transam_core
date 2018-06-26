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
  before_destroy    :unassociate_assets_and_events

  # Associations
  belongs_to :user, -> { unscope(where: :active) }
  belongs_to :organization
  belongs_to :file_status_type
  belongs_to :file_content_type
  # Asset events and assets can be created by bulk update
  has_many   :asset_events
  has_many   :assets

  # uploader
  mount_uploader :file, ExcelUploader

  validates :organization_id,       :presence => true, unless: Proc.new { |u| u.file_content_type_id == FileContentType.find_by(name: 'New Inventory').id }
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

  def organizations
    Organization.where(id: assets.pluck(:organization_id))
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

    # you cannot undo changes if you forced them
    unless force_update
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
      assets.destroy_all
    end
  end

  def updates
    updates = []

    if assets.empty?
      asset_events.each do |evt|
        updates << [evt.asset, evt]
      end
    else
      assets.each do |a|
        events = a.asset_events.where(upload_id: id)
        if events.empty?
          updates << [a, nil]
        else
          events.each do |evt|
            updates << [a, evt]
          end
        end
      end
    end

    updates
  end

  protected

  # Set resonable defaults for a new vehicle
  def set_defaults
    self.force_update = self.force_update.nil? ? false : self.force_update
    self.file_status_type_id ||= FileStatusType.find_by_name('Unprocessed').id
  end

  # Destroying an upload only removes the upload, events remain, but must be unassociated
  def unassociate_assets_and_events
    assets.update_all(upload_id: nil)
    asset_events.update_all(upload_id: nil)
  end

end
