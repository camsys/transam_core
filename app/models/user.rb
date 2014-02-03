#------------------------------------------------------------------------------
#
# User
#
# Base class for all users. This class represents a generic user.
#
#------------------------------------------------------------------------------
class User < ActiveRecord::Base

  # Enable auditing of this model type
  has_paper_trail :ignore => [:encrypted_password, :reset_password_token, :reset_password_sent_at, :current_sign_in_at, :sign_in_count, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip, :created_at, :updated_at]

  # Enable user roles for this use
  rolify

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :lockable, :recoverable, :rememberable, :trackable, :validatable, :timeoutable

  # Include the unique key mixin
  include UniqueKey

  #------------------------------------------------------------------------------
  # Overrides
  #------------------------------------------------------------------------------
  
  #require rails to use the key as the restful parameter. All URLS will be of the form
  # /user/{object_key}/...
  def to_param
    object_key
  end
  
  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults

  # Always generate a unique asset key before saving to the database
  before_validation(:on => :create) do
    generate_unique_key(:object_key)
  end
  
  # Associations
  
  # every user belongs to a single organizations
  belongs_to :organization
  
  # every user has access to 0 or more organizations for reporting
  has_and_belongs_to_many :organizations, :join_table => 'users_organizations'
  
  # Every user can have 0 or more messages
  has_many   :messages
  
  # Every user can have 0 or more files they have uploaded
  has_many   :uploads

  # Validations on core attributes
  validates :object_key,    :presence => true, :uniqueness => true
  validates :first_name,    :presence => true
  validates :last_name,     :presence => true
  validates :email,         :presence => true, :uniqueness => true
  validates :phone,         :presence => true
  validates :timezone,      :presence => true

  validates :email, :format => { :with => /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/, :message => "email address is not valid" }

  
  # search scope
  scope :search_query, lambda {|organization, search_text| {:conditions => [User.get_search_query_string(SEARCHABLE_FIELDS), {organization_id => organization.id, :search => search_text }]}}  
    
  SEARCHABLE_FIELDS = [
    :first_name,
    :last_name,
    :email,
    :phone,
  ] 
         
  # List of allowable form param hash keys  
  FORM_PARAMS = [
    :object_key,
    :organization_id,
    :first_name,
    :last_name,
    :phone,
    :timezone,
    :email,
    :password,
    :password_confirmation,
    :remember_me
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
          
  # Returns true if the user is in a specified role, false otherwise
  def is_in_role(role_id)
    ! roles.find(role_id).nil?
  end
      
  def name
    return first_name + " " + last_name unless new_record?
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new user
  def set_defaults
    self.timezone ||= 'Eastern Time (US & Canada)'
  end    

  #------------------------------------------------------------------------------
  #
  # Private Methods
  #
  #------------------------------------------------------------------------------
  private

  # constructs a query string for a search
  def self.get_search_query_string(searchable_fields)
    
    query_str = []
        
    query_str << 'organization_id = :agency_id'
    
    first = true
    
    searchable_fields.each do |field|
      if first
        first = false
        query_str << ' AND ('
      else
        query_str << ' OR '
      end
      
      query_str << field
      query_str << ' LIKE :search'
    end
    query_str << ')' unless searchable_fields.empty?
    
    return query_str.join      
  end
    
end
