#-------------------------------------------------------------------------------
# AuditRunnerJob
#
# Activity Job runner that runs an audit. The activity is set as the run time
# context. This is used to get the corresponding audit from the audit table
#-------------------------------------------------------------------------------
class IssuesReportJob < ActivityJob

  include TransamFormatHelper

  def run

    system_user = User.where(first_name: 'system', last_name: 'user').first

    event_url = Rails.application.routes.url_helpers.report_path(Report.find_by(name: 'Issues Report'))

    # send message to all admin about new issues created this week
    User.with_role(:admin).each do |user|
      msg               = Message.new
      msg.user          = system_user
      msg.organization  = system_user.organization
      msg.to_user       = user
      msg.subject       = "New Issues - Week of #{format_as_date(Date.today)}"
      msg.body          = "There are #{Issue.where(created_at: Date.today - 1.week, issue_status_type: IssueStatusType.find_by(name: 'Open')).count} new issue(s) in the last week. You can view all issues <a href='#{event_url}'>here</a>."
      msg.priority_type = PriorityType.default
      msg.save
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
