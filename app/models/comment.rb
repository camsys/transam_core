#-------------------------------------------------------------------------------
#
# Comment
#
# A comment that has been associated with another class such as a Task etc. This is a
# polymorphic class that can store comments against any class that includes a
# commentable association
#
# To use this class as an association with another class include the following line into
# the model
#
# has_many    :comments,  :as => :commentable
#
#-------------------------------------------------------------------------------
class Comment < ActiveRecord::Base

  # Include the object key mixin
  include TransamObjectKey

  # Callbacks
  after_initialize  :set_defaults

  # Associations
  belongs_to :commentable,  :polymorphic => true

  # Each comment was created by a user
  belongs_to :creator, :class_name => "User", :foreign_key => "created_by_id"

  validates :comment,             :presence => true
  validates :created_by_id,       :presence => true

  default_scope { order('created_at DESC') }

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :comment,
    :commentable_id,
    :commentable_type,
    :created_by_id
  ]

  # List of fields which can be searched using a simple text-based search
  SEARCHABLE_FIELDS = [
    :object_key,
    :comment
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

  def searchable_fields
    SEARCHABLE_FIELDS
  end

  def to_s
    comment
  end

  def description
    comment
  end

  # Return the organization of the owning object so instances can be index using
  # the keyword indexer
  def organization
    if commentable.respond_to? :organization
      commentable.organization
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

end
