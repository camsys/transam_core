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

  # Include the object key mixin
  include TransamObjectKey

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults

  # Clean up any HABTM associations before the user is destroyed
  before_destroy { :clean_habtm_relationships }

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------

  # every user belongs to a single organizations
  belongs_to :organization

  # every user has access to 0 or more organizations for reporting
  has_and_belongs_to_many :organizations, :join_table => 'users_organizations'
  has_many :organization_users, through: :organizations, :source => 'users'

  # Every user can have 0 or more messages
  has_many   :messages

  # Every user can have 0 or tasks assigned to them
  has_many   :tasks,        :foreign_key => :assigned_to_user_id

  # Every user can have a profile picture
  has_many   :images,      :as => :imagable,       :dependent => :destroy


  # Messages that have been tagged by the user
  has_many    :message_tags
  has_many    :messages, :through => :message_tags

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates :first_name,    :presence => true
  validates :last_name,     :presence => true
  validates :email,         :presence => true, :uniqueness => true, :format => { :with => /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/, :message => "email address is not valid" }
  validates :phone,         :presence => true
  validates :timezone,      :presence => true
  validates :num_table_rows,:presence => true, :numericality => {:only_integer => :true, :greater_than_or_equal_to => 5}
  validates :organization,  :presence => true

  # default scope
  default_scope { where(:active => true).order(:last_name) }

  SEARCHABLE_FIELDS = [
    :first_name,
    :last_name,
    :email,
    :phone,
  ]

  # List of allowable form param hash keys
  FORM_PARAMS = [
    :organization_id,
    :first_name,
    :last_name,
    :phone,
    :phone_ext,
    :timezone,
    :email,
    :title,
    :notify_via_email,
    :password,
    :password_confirmation,
    :current_password,
    :remember_me,
    :external_id,
    :num_table_rows,
    :active,
    :address1,
    :address2,
    :city,
    :state,
    :zip,
    :role_ids
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

  # Devise overrides for logging account locks/unlocks
  def lock_access!
    super
    # Send a message to the admins that the account has been locked
    Delayed::Job.enqueue LockedAccountInformerJob.new(object_key) unless new_record?
    # Log it
    Rails.logger.info "Locking account for user with email #{email} at #{Time.now}"
  end
  def unlock_access!
    super
    Rails.logger.info "Unlocking account for user with email #{email} at #{Time.now}"
  end

  def initials
    "#{first_name[0]}#{last_name[0]}"
  end

  # Returns true if the user is in a specified role, false otherwise
  def is_in_role(role_id)
    ! roles.find(role_id).nil?
  end

  # Returns true if the user has at least one of the roles. Roles can be strings
  # or symbols
  def is_in_roles?(roles_to_test)
    roles_to_test.each do |name|
      if roles_name.include? name.to_s
        return true
      end
    end
    false
  end

  def to_s
    name
  end

  def name
    "#{first_name} #{last_name}"
  end

  # This method defines required fields for any model which is geocodable
  def full_address
    elems = []
    elems << address1 unless address1.blank?
    elems << address2 unless address2.blank?
    elems << city unless city.blank?
    elems << state unless state.blank?
    elems << zip unless zip.blank?
    elems.compact.join(', ')
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
    self.state ||= SystemConfig.instance.default_state_code
    self.num_table_rows ||= 10
    self.notify_via_email ||= false
  end

  def clean_habtm_relationships
    organizations.clear
  end

  #------------------------------------------------------------------------------
  #
  # Private Methods
  #
  #------------------------------------------------------------------------------
  private

end
