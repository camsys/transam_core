#------------------------------------------------------------------------------
#
# TaskReminderJob
#
# Searches for tasks that are due and sends a message reminding
# the user that the task is due
#
# This task is designed to run once per day, every day
#
#------------------------------------------------------------------------------
class TaskReminderJob < Job
  
  include Rails.application.routes.url_helpers
    
  attr_accessor :days_from_now
  attr_accessor :priority_type
      
  def run

    # Get the system user
    sys_user = get_system_user

    # Get the task status types to search for
    task_statuses = []
    task_statuses << TaskStatusType.find_by_name('Not Started')
    task_statuses << TaskStatusType.find_by_name('In Progress')
    task_statuses << TaskStatusType.find_by_name('On Hold')
        
    # Get the list of tasks that are incomplete and due in days_from_now days
    date_due = Date.today + days_from_now.days

    tasks = Task.where('task_status_type_id IN (?) AND send_reminder = ? AND complete_by BETWEEN ? and ?', task_statuses, true, date_due.beginning_of_day, date_due.end_of_day)
    Rails.logger.info "Found #{tasks.count} incomplete tasks that are due in #{days_from_now} day(s)."

    tasks.each do |task|
      # Send a message to the assigned user for each task
      msg = Message.new
      msg.organization  = task.for_organization
      msg.user          = sys_user
      msg.to_user       = task.assigned_to
      msg.subject       = 'Incomplete Task Reminder'
      msg.body          = "<p>Task <strong>#{task.subject}</strong> is incomplete and is due to be completed by <strong>#{task.complete_by.strftime("%m-%d-%Y")}</strong>.</p><p>You can view this task by clicking <a href='#{user_task_path(task.assigned_to, task)}'>here</a></p>"
      msg.priority_type = priority_type
      msg.save      
    end
    
  end

  def prepare
    Rails.logger.info "Executing TaskReminderJob at #{Time.now.to_s} for tasks due in #{days_from_now} days."    
  end
  
  def check    
    raise ArgumentError, "days_from_now can't be nil " if days_from_now.nil?    
    raise ArgumentError, "priority_type can't be nil " if priority_type.nil?    
  end
  
  def initialize(days_from_now, priority_type)
    super
    self.days_from_now = days_from_now
    self.priority_type = priority_type
  end

end
