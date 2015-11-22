#-------------------------------------------------------------------------------
# UserRole
#
# User Role join table -- maps users to roles and vis versa. Provides additional
# ability to track when a role was added/updated, acrive roles, and who added
# or activated the role
#-------------------------------------------------------------------------------
class UsersRole < ActiveRecord::Base

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------

  # Every user role belongs to exactly one user
  belongs_to  :user

  # Every user role belongs to exactly one role
  belongs_to  :role

  # Every user role can have a granted by user
  belongs_to  :granted_by_user, :class_name => "User", :foreign_key => :granted_by_user_id

  # Every user role can have a revoked by user
  belongs_to  :revoked_by_user, :class_name => 'User', :foreign_key => :revoked_by_user_id

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates :user,    :presence => true
  validates :role,    :presence => true

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  default_scope { order(:created_at) }

  # tasks which are currently active based on the workflow
  scope :active, -> { where(:active => true) }

  # List of allowable form param hash keys
  FORM_PARAMS = [
    :id,
    :user_id,
    :role_id,
    :granted_by_user_id,
    :revoked_by_user_id,
  ]

  #------------------------------------------------------------------------------
  # Class Methods
  #------------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
  end

  #------------------------------------------------------------------------------
  # Instance Methods
  #------------------------------------------------------------------------------

  #------------------------------------------------------------------------------
  # Protected Methods
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new user role
  def set_defaults
    self.active ||= false
  end

  #------------------------------------------------------------------------------
  # Private Methods
  #------------------------------------------------------------------------------


end
