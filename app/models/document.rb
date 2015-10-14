#-------------------------------------------------------------------------------
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
#-------------------------------------------------------------------------------

# Include the FileSizevalidator mixin
require 'file_size_validator'

class Document < ActiveRecord::Base

  # From system config. This is the maximum document size that can be uploaded
  MAX_UPLOAD_FILE_SIZE = Rails.application.config.max_upload_file_size

  # Include the object key mixin
  include TransamObjectKey

  # Use the carrierway uploader
  mount_uploader :document,   DocumentUploader

  # Callbacks
  after_initialize  :set_defaults
  before_save       :update_file_attributes

  # Associations
  belongs_to :documentable,  :polymorphic => true

  # Each comment was created by a user
  belongs_to :creator, :class_name => "User", :foreign_key => "created_by_id"

  default_scope { order('created_at DESC') }

  validates :description,         :presence => true
  validates :original_filename,   :presence => true
  validates :document,            :presence => true, :file_size => { :maximum => MAX_UPLOAD_FILE_SIZE.megabytes.to_i }
  validates :created_by_id,       :presence => true

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :documentable_id,
    :documentable_type,
    :document,
    :description,
    :original_filename,
    :content_type,
    :file_size,
    :created_by_id
  ]

  SEARCHABLE_FIELDS = [
    :object_key,
    :description,
    :original_filename,
    :content_type
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

  def to_s
    name
  end

  def name
    original_filename
  end

  def searchable_fields
    SEARCHABLE_FIELDS
  end

  # Return the organiation of the owning object so instances can be index using
  # the keyword indexer
  def organization
    if documentable.respond_to? :organization
      documentable.organization
    end
  end

  #-----------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #-----------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new asset event
  def set_defaults

  end

  #-----------------------------------------------------------------------------
  #
  # Private Methods
  #
  #-----------------------------------------------------------------------------
  private

  def update_file_attributes

    if document.present? && document_changed?
      self.content_type = document.file.content_type
      self.file_size = document.file.size
    end
  end

end
