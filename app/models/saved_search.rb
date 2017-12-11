#-------------------------------------------------------------------------------
#
# Saved Search
#
# Represents a search that has been persisted to the database by the user. The
# user can set params to show the search in the dashboard, in the nav bar,
# and select wether to save the seasrch results as a *snapshot* which stores
# the selected rows' objects keys or as a *query* which will find matching rows
# based on the current state of the orders
#
#-------------------------------------------------------------------------------
class SavedSearch < ActiveRecord::Base

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
  belongs_to        :user

  belongs_to        :search_type

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates         :user,        :presence => true
  validates         :search_type, :presence => true
  validates         :name,        :presence => true, :uniqueness => {scope: :user, message: "should be unique per user"}
  validates         :description, :presence => true


  #-----------------------------------------------------------------------------
  # Scopes
  #-----------------------------------------------------------------------------

  # set the default scope
  default_scope { order("ordinal asc, created_at desc") }
  validates     :ordinal,     :numericality => {:only_integer => true, :greater_than => 0}, :allow_nil => true

  #-----------------------------------------------------------------------------
  # Constants
  #-----------------------------------------------------------------------------

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :ordinal,
    :search_type_id,
    :name,
    :description
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

  # Inflates a search proxy from the saved JSON
  def search_proxy
    if json.present?
      h = JSON.parse(json)
      h.except('errors', 'organization_id')
    end
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
