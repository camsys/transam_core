#------------------------------------------------------------------------------
#
# Task
#
# A task that has been associated with another class such as a Task etc. This is a
# polymorphic class that can store comments against any class that includes a
# commentable association
#
# To use this class as an association with another class include the following line into
# the model
#
# has_many    :tasks,  :as => :taskable, :dependent => :destroy
#
#------------------------------------------------------------------------------
class Task < ActiveRecord::Base

  # Include the object key mixin
  include TransamObjectKey

  # Include the Workflow module
  include TransamWorkflow

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------
  belongs_to :taskable,  :polymorphic => true

  # Every task is created by a user
  belongs_to :user

  # Every task is owned by an organization. This is the
  # organization that the task has been assigned to
  belongs_to :organization

  # Every task can be assigned to a user. This can be null
  # in which case the task will be available for everyone
  # in the :organization to take on
  belongs_to :assigned_to_user, :class_name => "User", :foreign_key => "assigned_to_user_id"

  # Every task is assigned a priority
  belongs_to :priority_type

  # Each task can have notes associated with it. Comments are destroyed when the task is destroyed
  has_many    :comments,  :as => :commentable, :dependent => :destroy

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates :user,                  :presence => true
  validates :priority_type,         :presence => true
  validates :organization,          :presence => true
  validates :subject,               :presence => true
  validates :body,                  :presence => true
  validates :complete_by,           :presence => true

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :user_id,
    :organization_id,
    :priority_type_id,
    :assigned_to_user_id,
    :subject,
    :state,
    :body,
    :send_reminder,
    :complete_by
  ]

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  default_scope { order('complete_by') }

  # tasks which are currently active based on the workflow
  scope :active, -> { where("state IN (?)", Task.active_states) }

  #------------------------------------------------------------------------------
  #
  # State Machine
  #
  # Used to track the state of a task order through the completion process
  #
  #------------------------------------------------------------------------------
  state_machine :state, :initial => :new do

    #-------------------------------
    # List of allowable states
    #-------------------------------

    # initial state. All tasks are created in this state
    state :new

    # state used to signify it has been started but not completed
    state :started

    # state used to signify it has been completed
    state :completed

    # state used to signify that work has been halted pending input
    state :halted

    # state used to indicate the task has been cancelled
    state :cancelled

    #---------------------------------------------------------------------------
    # List of allowable events. Events transition a task from one state to another
    #---------------------------------------------------------------------------

    # Retract the task from the shop. This is a terminal transition
    event :cancel do
      transition [:new, :started, :halted] => :cancelled
    end

    # start a task
    event :start do
      transition :new => :started
    end

    # restart a task
    event :restart do
      transition :halted => :started
    end

    # Mark a task as being complete
    event :complete do
      transition [:new, :started, :halted] => :completed
    end

    # The workorder has been started
    event :halt do
      transition [:new, :started] => :halted
    end

    # Callbacks
    before_transition do |task, transition|
      Rails.logger.debug "Transitioning #{task.name} from #{transition.from_name} to #{transition.to_name} using #{transition.event}"
    end
  end

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
  end

  def self.active_states
    ["new", "started", "halted"]
  end

  def self.terminal_states
    ["cancelled", "completed"]
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  def name
    subject
  end

  #------------------------------------------------------------------------------
  #
  # Private Methods
  #
  #------------------------------------------------------------------------------
  private

  # Set resonable defaults for a new asset
  def set_defaults
    self.state ||= :new
    self.send_reminder = self.send_reminder.nil? ? true : self.send_reminder
    self.complete_by ||= Date.today + 1.week
  end

end
