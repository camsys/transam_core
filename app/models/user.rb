#------------------------------------------------------------------------------
#
# User
#
# Base class for all users. This class represents a generic user.
#
#------------------------------------------------------------------------------
class User < ActiveRecord::Base

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

  # Every user has 0 or 1 user organization filter that they are using
  belongs_to :user_organization_filter
  
  # every user has access to 0 or more organizations for reporting
  has_and_belongs_to_many :organizations, :join_table => 'users_organizations'
  has_many :organization_users, through: :organizations, :source => 'users'
  
  # Every user can have 0 or more messages
  has_many   :messages

  # Every user can have 0 or more tasks
  has_many   :messages
  
  # Every user can have 0 or more files they have uploaded
  has_many   :tasks,        :foreign_key => :assigned_to_user_id

  # Every user can have a profile picture
  has_many    :images,      :as => :imagable,       :dependent => :destroy
  
  # Validations on core attributes
  validates :object_key,    :presence => true, :uniqueness => true
  validates :first_name,    :presence => true
  validates :last_name,     :presence => true
  validates :email,         :presence => true, :uniqueness => true, :format => { :with => /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/, :message => "email address is not valid" }
  validates :phone,         :presence => true
  validates :timezone,      :presence => true
  validates :num_table_rows,:presence => true, :numericality => {:only_integer => :true, :greater_than_or_equal_to => 5}
  validates :organization,  :presence => true
  
  # default scope
  default_scope { where(:active => true) }
      
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
    :title,
    :notify_via_email,
    :password,
    :password_confirmation,
    :remember_me,
    :external_id,
    :user_organization_filter_id,
    :num_table_rows,
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
          
  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------
          
  # Returns true if the user is in a specified role, false otherwise
  def is_in_role(role_id)
    ! roles.find(role_id).nil?
  end
      
  # Returns true if the user has at least one of the roles
  def is_in_roles?(roles_to_test)
    roles_to_test.each do |name|
      if roles_name.include? name
        return true
      end
    end
    false
  end
  
  def to_s
    name
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
    
end
