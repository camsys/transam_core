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
class TaskReminderJob < ActivityJob

  include Rails.application.routes.url_helpers

  def run

    # Get the system user
    sys_user = get_system_user

    # Get the task status types to search for
    task_statuses = Task.active_states


    [7,1].each do |days_from_now|
      # Get the list of tasks that are incomplete and due in days_from_now days
      date_due = Date.today + days_from_now.days

      tasks = Task.where('state IN (?) AND send_reminder = ? AND complete_by BETWEEN ? and ?', task_statuses, true, date_due.beginning_of_day, date_due.end_of_day)
      Rails.logger.info "Found #{tasks.count} incomplete tasks that are due in #{days_from_now} day(s)."

      message_template = MessageTemplate.find_by(name: 'Task1')

      msg_generator_service = MessageTemplateMessageGenerator.new

      tasks.each do |task|
        custom_fields = [task.subject, task.complete_by.strftime("%m/%d/%Y"),"<a href='#{user_task_path(task.assigned_to_user, task)}'>here</a>"]
        message_body = msg_generator_service.generate(message_template, custom_fields)

        # Send a message to the assigned user for each task
        msg = Message.new
        msg.organization  = task.organization
        msg.user          = sys_user
        msg.to_user       = task.assigned_to_user
        msg.subject       = message_template.subject
        msg.body          = message_body
        msg.priority_type = days_from_now < 2 ? PriorityType.find_by_name('High') : message_template.priority_type
        msg.save
      end
    end

    # Add a row into the activity table
    # add to activity log for all admin users
    User.with_role(:admin).pluck('DISTINCT organization_id').each do |org_id|
      ActivityLog.create({:organization_id => org_id, :user_id => sys_user.id, :item_type => self.class.name, :activity => 'Sent reminders for tasks due', :activity_time => Time.now})
    end

  end

  def prepare
    Rails.logger.info "Executing TaskReminderJob at #{Time.now.to_s} for tasks due."
  end

end
