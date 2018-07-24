#------------------------------------------------------------------------------
#
# Organization
#
# Represents a basic organization in a flat organizational hierarchy
# without any relationships to other organizations or assets
#
#------------------------------------------------------------------------------
class Organization < ActiveRecord::Base

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults

  scope :active, -> { where(:active => true) }

  #------------------------------------------------------------------------------
  # Overrides
  #------------------------------------------------------------------------------
  #require rails to use the org short name as the restful parameter. All URLS will be of the form
  # /org/{short_name}/...
  def to_param
    short_name
  end

  #------------------------------------------------------------------------------
  # Associations common to all organizations
  #------------------------------------------------------------------------------

  # Every organization belongs to a customer
  belongs_to :customer

  # Every organization has a class type
  belongs_to :organization_type

  # Every organization can have a set of users
  has_and_belongs_to_many :users, :join_table => 'users_organizations'

  # Every organization can have messages
  has_many  :messages

  # Every organization can have a set of uploads
  has_many  :uploads

  # Every organization can have 0 or more asset groups
  has_many  :asset_groups

  # Every organization can have 0 or more vendors
  has_many  :vendors

  # Validations for associations
  validates :customer_id,           :presence => true
  validates :organization_type_id,  :presence => true

  #------------------------------------------------------------------------------
  # Attributes common to all organization types
  #------------------------------------------------------------------------------

  validates :name,                  :presence => true
  validates :short_name,            :presence => true, :uniqueness => true
  validates :address1,              :presence => true
  validates :city,                  :presence => true
  validates :state,                 :presence => true
  validates :zip,                   :presence => true
  #validates :license_holder, :presence => true
  validates :phone,                 :presence => true
  validates :url,                   :presence => true

  # List of allowable form param hash keys
  FORM_PARAMS = [
    :customer_id,
    :organization_type_id,
    :external_id,
    :license_holder,
    :name,
    :short_name,
    :address1,
    :address2,
    :city,
    :state,
    :zip,
    :phone,
    :fax,
    :url,
    :active
  ]

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
  end

  # returns a typed value of the organization if one exists
  def self.get_typed_organization(org)
    if org
      class_name = org.organization_type.class_name
      klass = Object.const_get class_name
      o = klass.find(org.id)
      return o
    end
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  # Returns the user with the assigned role :technical_contact
  def technical_contact
    usrs = users_with_role :technical_contact
    if usrs.empty?
      nil
    else
      usrs.first
    end
  end

  # Returns the users in the organiztion with the assigned role
  def users_with_role role_name
    users.with_role role_name
  end

  #-----------------------------------------------------------------------------
  # Returns a hash of asset_type_ids and the counts per non-zero type
  #-----------------------------------------------------------------------------
  def asset_type_counts(active_only=true)
    if active_only
      Asset.operational.where(:organization => self).group(:asset_type_id).count
    else
      Asset.where(:organization => self).group(:asset_type_id).count
    end
  end

  #-----------------------------------------------------------------------------
  # Returns a hash of asset subtype ids and the counts per non-zero type
  #-----------------------------------------------------------------------------
  def asset_subtype_counts(asset_type_id, active_only=true)
    if active_only
      Asset.operational.where(:organization => self, :asset_type_id => asset_type_id).group(:asset_subtype_id).count
    else
      Asset.where(:organization => self, :asset_type_id => asset_type_id).group(:asset_subtype_id).count
    end
  end

  #-----------------------------------------------------------------------------
  # Returns true if the organization is of the specified class or has the specified class as
  # and ancestor (superclass).
  #
  # usage: a.type_of? type
  # where type can be one of:
  #    a symbol e.g :grantee
  #    a class name eg Grantee
  #    a string eg "grantee"
  #
  #-----------------------------------------------------------------------------
  def type_of?(type)
    begin
      self.class.ancestors.include?(type.to_s.classify.constantize)
    rescue
      false
    end
  end

  def coded_name
    "#{short_name}-#{name}"
  end

  def object_key
    "#{short_name}"
  end

  def to_s
    short_name
  end

  # Generic organizations do not own transit assets
  def has_assets?
    false
  end

  # Returns a policy for this org. This must be overriden for concrete classes
  def get_policy
    # get a typed version of the organization and return its value
    org = is_typed? ? self : Organization.get_typed_organization(self)
    return org.get_policy unless org.nil?
  end

  # returns true if the organization instance is strongly typed, i.e., a concrete class
  # false otherwise.
  # true
  def is_typed?
    self.class.to_s == organization_type.class_name
  end

  # Returns the organization sub-heirarchy rooted at this organization. The
  # method returns this organization and all below it
  def organization_hierarchy
    a = []
    # Perform a depth-first traversal of the org tree
    a << self
    children = Organization.where(:parent_id => self.id)
    children.each do |child|
      a += child.organization_hierarchy
    end
    a.uniq
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new organization
  def set_defaults
    self.active = self.active.nil? ? true : self.active
    self.state ||= SystemConfig.instance.try(:default_state_code)
  end

end
