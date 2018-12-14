#-------------------------------------------------------------------------------
#
# Saved Query
#
# Represents a search that has been persisted to the database by the user
#
#-------------------------------------------------------------------------------
class SavedQuery < ActiveRecord::Base

  #-----------------------------------------------------------------------------
  # Behaviors
  #-----------------------------------------------------------------------------

  # Include the object key mixin
  include TransamObjectKey

  #-----------------------------------------------------------------------------
  # Callbacks
  #-----------------------------------------------------------------------------
  after_initialize  :set_defaults

  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  # Each saved search belongs to a user
  belongs_to        :created_by_user, :class_name => "User",  :foreign_key => :created_by_user_id
  belongs_to        :updated_by_user, :class_name => "User",  :foreign_key => :updated_by_user_id
  belongs_to        :shared_from_org, :class_name => "Organization",  :foreign_key => :shared_from_org_id

  has_and_belongs_to_many   :organizations

  has_many :saved_query_fields
  has_many :query_filters

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates         :created_by_user,        :presence => true
  validates         :updated_by_user,        :presence => true
  validates         :name,        :presence => true, :uniqueness => {scope: :created_by_user, message: "should be unique per user"}
  validates         :description, :presence => true


  #-----------------------------------------------------------------------------
  # Scopes
  #-----------------------------------------------------------------------------


  #-----------------------------------------------------------------------------
  # Constants
  #-----------------------------------------------------------------------------

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :name,
    :description,
    :organization_ids => []
  ]

  # List of fields which can be searched using a simple text-based search
  SEARCHABLE_FIELDS = [
    :name,
    :description
  ]

  #-----------------------------------------------------------------------------
  #
  # Class Methods
  #
  #-----------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
  end

  def self.searchable_fields
    SEARCHABLE_FIELDS
  end

  #-----------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #-----------------------------------------------------------------------------

  def to_s
    name
  end

  def shared?
    !organizations.empty?
  end

  #-----------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #-----------------------------------------------------------------------------
  protected

  # Set reasonable defaults for a new saved search
  def set_defaults

  end

end
