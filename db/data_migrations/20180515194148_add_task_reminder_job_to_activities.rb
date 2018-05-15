class AddTaskReminderJobToActivities < ActiveRecord::DataMigration
  def up
    Activity.create!(
        {:name => 'Task Reminders', :description => 'Send messages to users with task reminders for tasks due in a day or week.', :job_name => 'TaskReminderJob', :frequency_quantity => 1, :frequency_type_id => 3, :execution_time => '08:00', :show_in_dashboard => true, :active => true}
    )
  end
end