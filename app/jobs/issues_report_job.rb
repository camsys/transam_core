#-------------------------------------------------------------------------------
# AuditRunnerJob
#
# Activity Job runner that runs an audit. The activity is set as the run time
# context. This is used to get the corresponding audit from the audit table
#-------------------------------------------------------------------------------
class IssuesReportJob < ActivityJob

  include TransamFormatHelper

  def run

    message_template = MessageTemplate.find_by(name: 'Support1', active: true)
    if message_template.present?
      system_user = User.where(first_name: 'system', last_name: 'user').first

      event_url = Rails.application.routes.url_helpers.report_url(Report.find_by(name: 'Issues Report'))

      # send message to all admin about new issues created this week
      activity = Activity.find_by(job_name: self.class.name)
      frequency = activity.frequency_type.name
      new_issues = Issue.where(issue_status_type: IssueStatusType.find_by(name: 'Open')).where('created_at >= ?', Date.today - (activity.frequency_quantity).send(frequency))

      message_body = MessageTemplateMessageGenerator.new.generate(message_template, [new_issues.count, frequency, "<a href='#{event_url}'>here</a>"])

      if new_issues.count > 0
        User.with_role(:admin).each do |user|
          msg               = Message.new
          msg.user          = system_user
          msg.organization  = system_user.organization
          msg.to_user       = user
          msg.subject       = message_template.subject
          msg.body          = message_body
          msg.priority_type = message_template.priority_type
          msg.message_template = message_template
          msg.save
        end
      end

      write_to_activity_log system_user.organization, "Issues Report sent to admin users"
    end

  end

  def clean_up
    super
    Rails.logger.debug "Completed IssuesReportJob at #{Time.now.to_s}"
  end

  def prepare
    super
    Rails.logger.debug "Executing IssuesReportJob at #{Time.now.to_s}"
  end
end
