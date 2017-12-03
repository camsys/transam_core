#-------------------------------------------------------------------------------
#
# Activity
#
# Represents a process that is run on a schedule like a cron job. Activities can
# include system level processes, audits, and other activities.
#
#-------------------------------------------------------------------------------
class Activity < ActiveRecord::Base

  # Include the object key mixin
  include TransamObjectKey

  #-----------------------------------------------------------------------------
  # Callbacks
  #-----------------------------------------------------------------------------
  after_initialize  :set_defaults

  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  # Every activity has a frequency_type eg hour, minute, day, etc.
  belongs_to :frequency_type

  #-----------------------------------------------------------------------------
  # Scopes
  #-----------------------------------------------------------------------------
  scope :active, -> { where(:active => true) }

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates :name,              :presence => true
  validates :description,       :presence => true
  validates_inclusion_of :show_in_dashboard,  :in => [true, false]
  validates_inclusion_of :system_activity,    :in => [true, false]
  #validates :start_date,        :allow_nil => true
  #validates :end_date,          :allow_nil => true
  validates :frequency_quantity, :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 1}
  validates :frequency_type,    :presence => true
  validates :job_name,          :presence => true
  validates_inclusion_of :active, :in => [true, false]

  # List of allowable form param hash keys
  FORM_PARAMS = [
    :name,
    :description,
    :show_in_dashboard,
    :system_activity,
    :start_date,
    :end_date,
    :frequency_quantity,
    :frequency_type_id,
    :execution_time,
    :job_name,
    :active
  ]

  #-----------------------------------------------------------------------------
  # Class Methods
  #-----------------------------------------------------------------------------
  def self.allowable_params
    FORM_PARAMS
  end

  #-----------------------------------------------------------------------------
  # Instance Methods
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Returns true if this job is operational on the current day. If the start_date
  # and end date are set the current date should be in the range, if they are not
  # set this always returns true
  #-----------------------------------------------------------------------------
  def operational?
    if start_date.blank?
      true
    else
      if end_date.blank? or end_date < start_date
        false
      else
        today = Date.today
        (start_date <= today and end_date >= today)
      end
    end
  end

  def to_s
    name
  end

  # Returns a string description of this activities execution schedule
  def schedule
    "#{frequency_quantity} #{frequency_type.name.pluralize} at #{execution_time}"
  end

  # Used by clockwork to schedule how frequently this event should be run
  # Should be the intended number of seconds between executions
  def frequency
    frequency_quantity.send(frequency_type.name.pluralize)
  end

  # Used by clockwork to specify when to trigger an event
  def at
    execution_time
  end

  # Returns the job that will be executed
  def job
    job_name.constantize.new({
      :context => self
    })
  end
  #-----------------------------------------------------------------------------
  # Protected Methods
  #-----------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new organization
  def set_defaults
    self.active = self.active.nil? ? true : self.active
    self.show_in_dashboard = self.show_in_dashboard.nil? ? true : self.show_in_dashboard
    self.system_activity = self.system_activity.nil? ? false : self.system_activity
    self.frequency_quantity ||= 1
  end

end
