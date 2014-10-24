#------------------------------------------------------------------------------
#
# ActivityJob
#
# Special type of job that can be configured to perform different actions at
# different times. Each reminder job has:
#
# name      -- unique name for the reminder
# activity  -- a description of the activities that are requried. This is repesented to the
#              users to describe what they need to do.
# due       -- describes when the activity is due.
# notify    -- describes when to start to notify the user of the activity deadline
# warn      -- describes when to start to warn the user of the activity deadline 
# alert     -- describes when to start to alert the user of the activity deadline
# escalate  -- describes when to start to escalate notifications that the activity is not
#              complete
# 
# ActivityJob uses Chronic to describe when activities are due
# and any string that chronic can parse can be used to describe an activity due time/date. 
# Note that all actions are relative to the time that the job is being executed 
# so "today" will match every day that the scheduler runs and "Jan 1" will return
# the next matching date, Jan 1 2015 for example, or on Jan 2 2015, it will return
# Jan 1 2016.
#
# notifications (notify, warn, alert, escalate) should be relative to the due date so 
# notify = "1 month before" would start the notification process exactly 1 month 
# before the date/time that the activity is due. The expression syntax for the notifications
# is x minute|day|week|month|year before|after where x is an integer. Plural versions of
# the durations can also be used so minutes, weeks, months, years also work.
#
# Example:
#  due = "1st day next month"
#  notify = "1 week before"
#  warn = "2 days before"
#  alert = "1 day after"
#
#  This will result in the following Chronic expressions if today is 10/10/2014
#   @due_date_time = Chronic.parse("first day next month") =  2014-11-01 12:00:00 -0400
#   @notify_date_time = @due_date_time - 1.week = 2014-10-25 12:00:00 -0400
#   @warn_date_time =  @due_date_time - 2.day = 2014-10-30 12:00:00 -0400
#   @alert_date_time =  @due_date_time + 1.day =  2014-11-02 12:00:00 -0500
#
# If any of the notifications are blank they will be skipped.
#
#------------------------------------------------------------------------------
class ActivityJob < Job
  
  attr_reader :name
  attr_reader :activity_description
  attr_reader :due
  attr_reader :notify
  attr_reader :notify_complete
  attr_reader :warn
  attr_reader :warn_complete
  attr_reader :alert
  attr_reader :alert_complete
  attr_reader :escalate
  attr_reader :esaclate_complete
  
  attr_reader :due_date_time
  attr_reader :notify_date_time
  attr_reader :warn_date_time
  attr_reader :alert_date_time
  
  def initialize(args = {})
    super(args)
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end  
  
  # Make sure that the due date/time expression can be parsed
  def check    
    raise ArgumentError, "Can't parse '#{@due}' expression" if Chronic.parse(@due).nil?
    unless @notify.blank?
      raise ArgumentError, "Can't parse '#{@notify}' expression" if parse_expression(@notify).nil?      
    end
    unless @warn.blank?
      raise ArgumentError, "Can't parse '#{@warn}' expression" if parse_expression(@warn).nil?      
    end
    unless @alert.blank?
      raise ArgumentError, "Can't parse '#{@alert}' expression" if parse_expression(@alert).nil?      
    end
    true
  end

  # Set up the action times if they are set  
  def prepare
    Rails.logger.debug "Executing ReminderJob at #{Time.now.to_s}"    
    @due_date_time = Chronic.parse(@due)
    @notify_date_time = evaluate(@due_date_time, @notify) unless @notify.blank?
    @warn_date_time = evaluate(@due_date_time, @warn)  unless @warn.blank?
    @alert_date_time = evaluate(@due_date_time, @alert)  unless @alert.blank?
  end  
  
  
  protected
  
  # evaluate the expression. Returns nil if the expression fails
  def evaluate(due_date, expression)
    a = parse_expression(expression)
    if a
      val = eval("due_date #{a[:operator]} #{a[:count]}.#{a[:type]}")
    end
    val
  end
  # parse the notification expression which has the pattern
  #
  # x minute|day|week|month|year before|after
  # 
  def parse_expression(str)
    elems = str.split(' ')
    if elems.length == 3
      return unless elems[0].to_i > 0
      return unless %w(minute minutes day days week weeks month months year years).include? elems[1].downcase
      return unless %w(before after).include? elems[2].downcase
      a = {}
      a[:count] = elems[0].to_i
      a[:type] = elems[1].downcase
      a[:operator] = elems[2].downcase == 'after' ? '+' : '-' 
    end
    a
  end

  # Get the system user
  def get_system_user
    User.where('first_name = ? AND last_name = ?', 'system', 'user').first
  end
  
end