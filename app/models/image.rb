#-------------------------------------------------------------------------------
#
# Image
#
# An Image(photo) that has been associated with another class such as an Asset etc. This is a
# polymorphic class that can store images against any class that includes a
# imagable association
#
# To use this class as an association with another class include the following line into
# the model
#
# has_many    :images,  :as => :imagable
#
#-------------------------------------------------------------------------------

# Include the FileSizevalidator mixin
require 'file_size_validator'

class Image < ActiveRecord::Base

  # Include the object key mixin
  include TransamObjectKey

  # From system config. This is the maximum document size that can be uploaded
  MAX_UPLOAD_FILE_SIZE = Rails.application.config.max_upload_file_size

  # Use the carrierwave uploader
  mount_uploader :image,      ImageUploader

  # Callbacks
  after_initialize  :set_defaults
  before_save       :update_file_attributes

  # Associations
  belongs_to :base_imagable, :polymorphic => true
  belongs_to :imagable,  :polymorphic => true

  # Each comment was created by a user
  belongs_to :creator, :class_name => "User", :foreign_key => "created_by_id"

  validates :description,         :presence => true,
    unless: Proc.new { |i| i.imagable.is_a? User } # User profile photos do not need a description
  validates :original_filename,   :presence => true
  validates :image,               :presence => true, :file_size => { :maximum => MAX_UPLOAD_FILE_SIZE.megabytes.to_i }
  validates :created_by_id,       :presence => true

  default_scope { order('created_at DESC') }

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :base_imagable_type,
    :base_imagable_id,
    :global_base_imagable,
    :imagable_id,
    :imagable_type,
    :global_imagable,
    :image,
    :classification,
    :name,
    :description,
    :exportable,
    :original_filename,
    :content_type,
    :file_size,
    :created_by_id
  ]

  # List of fields which can be searched using a simple text-based search
  SEARCHABLE_FIELDS = [
    :object_key,
    :original_filename,
    :description,
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
    read_attribute(:name).present? ? read_attribute(:name) : original_filename
  end

  def searchable_fields
    SEARCHABLE_FIELDS
  end

  # Return the organization of the owning object so instances can be index using
  # the keyword indexer
  def organization
    if imagable.respond_to? :organization
      imagable.organization
    else
      creator.organization
    end
  end

  # https://neanderslob.com/2015/11/03/polymorphic-associations-the-smart-way-using-global-ids/
  # following this article we set fta_type based on the fta asset class ie the model
  def global_base_imagable
    self.base_imagable.to_global_id if self.base_imagable.present?
  end
  def global_base_imagable=(imagable)
    self.base_imagable=GlobalID::Locator.locate imagable
  end
  def global_imagable
    self.imagable.to_global_id if self.imagable.present?
  end
  def global_imagable=(imagable)
    self.imagable=GlobalID::Locator.locate imagable
  end

  #-----------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #-----------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new asset event
  def set_defaults
    self.exportable = self.exportable.nil? ? false : self.exportable
  end

  #-----------------------------------------------------------------------------
  #
  # Private Methods
  #
  #-----------------------------------------------------------------------------
  private

  def update_file_attributes

    if image.present? && image
      self.content_type = image.file.content_type
      self.file_size = image.file.size
    end
  end

end
