class UserOrganizationFilter < ActiveRecord::Base
  
  # Include the unique key mixin
  include UniqueKey
  
  #require rails to use the key as the restful parameter
  def to_param
    object_key
  end
  
  # Always generate a unique asset key before saving to the database
  before_validation(:on => :create) do
    generate_unique_key(:object_key)
  end

  # Callbacks
  after_initialize :set_defaults
  after_save       :require_at_least_one_organization     # validate model for HABTM relationships
  
  # Clean up any HABTM associations before the asset is destroyed
  before_destroy { :clean_habtm_relationships }
  
  # Each filter is owned by a specific user
  belongs_to  :user

  # Each filter can have a list of organizations that are included
  has_and_belongs_to_many :organizations, :join_table => 'user_organization_filters_organizations'
  
  validates   :user_id,       :presence => :true
  validates   :name,          :presence => :true
  validates   :description,   :presence => :true
  
  # default scope
  default_scope { where(:active => true) }
  
  # Named Scopes
  scope :system_filters, -> { where('user_id = ? AND active = ?', 1, 1 ) }  

  # List of allowable form param hash keys  
  FORM_PARAMS = [
    :object_key,
    :user_id,
    :name,
    :description,
    :organization_ids => []
  ]
  
  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------
  
  def self.allowable_params
    FORM_PARAMS
  end
  
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
    self.active ||= true
  end    
  
  
end
