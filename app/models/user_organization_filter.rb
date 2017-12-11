class UserOrganizationFilter < ActiveRecord::Base

  # Include the unique key mixin
  include TransamObjectKey

  # Callbacks
  after_initialize :set_defaults

  # Clean up any HABTM associations before the asset is destroyed
  #before_destroy { :clean_habtm_relationships }

  belongs_to :resource, :polymorphic => true

  # Each filter is created by someone usually the owner but sometimes the system user (could be extended to sharing filters)
  belongs_to :creator, :class_name => "User", :foreign_key => :created_by_user_id

  # Each filter can have a list of organizations that are included
  has_and_belongs_to_many :organizations, :join_table => 'user_organization_filters_organizations'

  has_and_belongs_to_many :users, :join_table => 'users_user_organization_filters'

  validates   :name,          :presence => true
  validates   :description,   :presence => true
  #validate    :require_at_least_one_organization

  # Allow selection of active instances
  scope :active, -> { where(:active => true) }
  # sorting rule: 1. first sort ASC based on sort_order; 2. for those without sort_order, sort by name ASC
  scope :sorted, -> { order('sort_order IS NULL, sort_order ASC', :name) }

  # Named Scopes
  scope :system_filters, -> { where('created_by_user_id = ? AND active = ?', 1, 1 ) }
  scope :other_filters, -> { where('created_by_user_id > ? AND active = ?', 1, 1 ) }

  # List of allowable form param hash keys
  FORM_PARAMS = [
    :name,
    :description,
    :organization_ids
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

  # Returns true if this is a system filter
  def system_filter?
    UserOrganizationFilter.system_filters.include? self
  end

  def shared?
    self.users.count > 1
  end

  def get_organizations
    self.query_string.present? ? Organization.find_by_sql(self.query_string) : self.organizations
  end

  def can_update? user
    !self.system_filter? && (self.users.include? user)
  end

  def can_destroy? user
    !self.system_filter? && (self.users.include? user) && self != user.user_organization_filter
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------

  protected

  def require_at_least_one_organization
    if organizations.count == 0
      errors.add(:organizations, "must be selected.")
      return false
    end
  end

  def clean_habtm_relationships
    organizations.clear
  end

  private
  # Set resonable defaults for a new filter
  def set_defaults
    self.active = self.active.nil? ? true : self.active
  end


end
