#-------------------------------------------------------------------------------
# User
#
# Base class for all users. This class represents a generic user.
#-------------------------------------------------------------------------------
class User < ActiveRecord::Base

  # Enable user roles for this use
  rolify

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :lockable, :recoverable, :rememberable, :trackable, :validatable, :timeoutable

  # Include the object key mixin
  include TransamObjectKey

  #-----------------------------------------------------------------------------
  # Callbacks
  #-----------------------------------------------------------------------------
  after_initialize  :set_defaults

  # Clean up any HABTM associations before the user is destroyed
  before_destroy { :clean_habtm_relationships }

  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------

  has_many :users_roles, -> { active }, :inverse_of => :user
  has_many :roles,      :through => :users_roles

  # every user belongs to a single organizations
  belongs_to :organization

  # Every user can have a weather code associated with their city. This is used
  # to display local weather on the dashboard
  belongs_to  :weather_code

  # Every user has 0 or 1 user organization filter that they are using and a list that they own
  belongs_to :user_organization_filter
  has_and_belongs_to_many :user_organization_filters, :join_table => 'users_user_organization_filters'

  # every user has access to 0 or more organizations for reporting
  has_and_belongs_to_many :organizations, :join_table => 'users_organizations'
  has_many :organization_users, -> {uniq}, through: :organizations, :source => 'users'

  # Every user can have 0 or more messages
  has_many   :messages

  # Every user can have 0 or tasks assigned to them
  has_many   :tasks,        :foreign_key => :assigned_to_user_id

  # Every user can have a profile picture
  has_many   :images,      :as => :imagable,       :dependent => :destroy


  # Messages that have been tagged by the user
  has_many    :message_tags
  has_many    :messages, :through => :message_tags

  # Notifications
  has_many    :user_notifications

  # Assets that have been tagged by the user
  has_many    :asset_tags
  has_many    :assets, :through => :asset_tags

  # AssetEvents that have been tagged by the user
  has_many    :asset_events,  :foreign_key => :created_by_id

  #
  has_many    :saved_searches

  #-----------------------------------------------------------------------------
  # Transients
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates :first_name,    :presence => true,  :length => { maximum: 64 }
  validates :last_name,     :presence => true,  :length => { maximum: 64 }
  validates :external_id,   :allow_nil => true, :length => { maximum: 32 }
  validates :title,         :allow_nil => true, :length => { maximum: 64 }

  #validates :email,         :presence => true,  :length => { maximum: 128 },  :uniqueness => true, :format => { :with => /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/, :message => "email address is not valid" }
  validates :phone,         :presence => true,  :length => { maximum: 12 }
  validates :phone_ext,     :allow_nil => true, :length => { maximum: 6 }
  validates :timezone,      :presence => true,  :length => { maximum: 32 }

  validates :address1,      :allow_nil => true, :length => { maximum: 32 }
  validates :address2,      :allow_nil => true, :length => { maximum: 32 }
  validates :city,          :allow_nil => true, :length => { maximum: 32 }
  validates :state,         :allow_nil => true, :length => { maximum: 2 }
  validates :zip,           :allow_nil => true, :length => { maximum: 12 }

  validates :num_table_rows,:presence => true,  :numericality => {:only_integer => true, :greater_than_or_equal_to => 5}
  validates :organization,  :presence => true

  #-----------------------------------------------------------------------------
  # Scopes
  #-----------------------------------------------------------------------------
  # default scope
  default_scope { order(:last_name) }
  # Scope only active users
  scope :active, -> { where(active: true) }

  #-----------------------------------------------------------------------------
  # Lists
  #-----------------------------------------------------------------------------
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
    :weather_code_id,
    :active,
    :address1,
    :address2,
    :city,
    :state,
    :zip,
    :role_ids,
    :privilege_ids,
    :user_organization_filter_id,
    :organization_ids
  ]

  #-----------------------------------------------------------------------------
  # Class Methods
  #-----------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
  end

  # set default widgets and the column they are in. these can be customized at the app level
  def self.dashboard_widgets
    return Rails.application.config.dashboard_widgets if Rails.application.config.try(:dashboard_widgets)

    widgets = []
    SystemConfig.transam_module_names.each do |mod|
      view_component = "#{mod}_widget"
      widgets << [view_component, 2]
    end
    widgets += [
        ['assets_widget', 1],
        #['activities_widget', 1],
        ['queues', 1],
        ['users_widget', 1],
        ['notices_widget', 3],
        ['search_widget', 3],
        ['message_queues', 3],
        ['task_queues', 3]
    ]

    return widgets

  end

  #-----------------------------------------------------------------------------
  # Instance Methods
  #-----------------------------------------------------------------------------

  # Returns the default weather code for the users dashboard
  def default_weather_code
    if weather_code
      weather_code.code
    else
      Rails.application.config.default_weather_code
    end
  end

  # Get the new messages for the current user
  def new_messages
    Message.where('to_user_id = ? AND opened_at IS NULL', id).order("created_at DESC")
  end

  # Gets the tasks for the current user that are still open
  def assigned_tasks
    Task.where("assigned_to_user_id = ? AND state IN (?)", id, ["new", "started", "halted"]).order(:complete_by)
  end
  def due_tasks
    today = Date.today
    assigned_tasks.where("complete_by < ?",  Date.today.end_of_day)
  end
  def new_tasks
    assigned_tasks.where(:state => "new")
  end
  def started_tasks
    assigned_tasks.where(:state => "started")
  end
  def on_hold_tasks
    assigned_tasks.where(:state => "halted")
  end

  # Returns the initials for this user
  def get_initials
    "#{first_name[0]}#{last_name[0]}".upcase
  end

  # Getter for privileges
  def privileges
    roles.privileges
  end
  # Getter for privileges
  def privilege_ids
    a = []
    privileges.each{|x| a << x.id}
    a
  end

  # Returns the user's primary role. This is the role which has the highest
  # weight. User < Manager < Regional Manager < CMO < CEO where CEO has the
  # highest weight
  def primary_role
    roles.roles.order(:weight).last
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

  def searchable_fields
    SEARCHABLE_FIELDS
  end

  def update_user_organization_filters
    self.user_organization_filters = UserOrganizationFilter.joins(:users).where(created_by_user_id: self.id).sorted.group('user_organization_filters.id').having( 'count( user_id ) = 1' )

    UserOrganizationFilter.where('resource_type IS NOT NULL').each do |filter|
      puts self.try(filter.resource_type.downcase.pluralize).include? filter.resource
      puts self.organizations.inspect
      if self.respond_to? filter.resource_type.downcase.pluralize #check has many associations
        if self.try(filter.resource_type.downcase.pluralize).include? filter.resource
          self.user_organization_filters << filter
        end
      elsif self.respond_to? filter.resource_type.downcase # check single association
        if self.try(filter.resource_type.downcase) == filter.resource
          self.user_organization_filters << filter
        end
      end
    end

    if self.user_organization_filters.system_filters.count == 0
      f = UserOrganizationFilter.new({:active => 1, :name => "#{self.name}'s organizations", :description => "#{self.name}'s organizations", :sort_order => 1})
      f.users = [self]
      f.creator = User.find_by(first_name: 'system')
      f.query_string = Organization.active.joins(:users).where('users_organizations.user_id = ?', self.id).to_sql
      f.save!
    end

    if self.user_organization_filter.nil? || !(self.user_organization_filters.include? self.user_organization_filter)
      self.user_organization_filter = self.user_organization_filters.system_filters.first
    end

    self.save!
  end

  #-----------------------------------------------------------------------------
  # Devise hooks
  #-----------------------------------------------------------------------------

  # check if the user is active and can log in
  def active_for_authentication?
    # Log it
    unless self.active
      Rails.logger.info "Attempted access to in-active account for user with email #{email} at #{Time.now}"
    end

    super && self.active
  end

  def inactive_message
    "Sorry, this account has been deactivated."
  end

  # Overrides for logging account locks/unlocks
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
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Protected Methods
  #-----------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new user
  def set_defaults
    self.timezone ||= 'Eastern Time (US & Canada)'
    self.state ||= SystemConfig.instance.default_state_code
    self.num_table_rows ||= 10
    self.notify_via_email ||= false
    self.failed_attempts ||= 0
    self.active ||= false
  end

  def clean_habtm_relationships
    organizations.clear
  end

  #-----------------------------------------------------------------------------
  # Private Methods
  #-----------------------------------------------------------------------------
  private

end
