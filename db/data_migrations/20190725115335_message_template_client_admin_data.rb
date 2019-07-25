class MessageTemplateClientAdminData < ActiveRecord::DataMigration
  def up
    Role.create!(name: 'client_admin', role_parent: Role.find_by(name: 'admin'), weight: 1, privilege: true, show_in_user_mgmt: false)

    MessageTemplate.create!(name: 'Task1', delivery_rules: 'Sent when tasks are due less than or a week from now', subject: 'Incomplete Task Reminder', body: "<p>Task <strong>{subject}</strong> is incomplete and is due to be completed by <strong>{complete_by_date}</strong>.</p><p>You can view this task by clicking {link(here)}</p>", active: true, is_implemented: true)

    MessageTemplate.create!(name: 'Support1', delivery_rules: 'Sent x days/weeks/months (Activity defines) if new issues to admins', subject: "New Issues Report", body: "There are {new_issues.count} new issue(s) in the last {frequency}. You can view all issues {link(here)}.", active: true, is_implemented: true)

    MessageTemplate.create!(name: 'Support2', delivery_rules: 'Sent when a template is added or changed', subject: "Message Template Changes", body: "The following message template {name} with the subject {subject} has changed. Please review for implementation changes.", active: true, is_implemented: true)

   MessageTemplate.create!(name: 'User1', delivery_rules: 'Sent to new user',  subject: "A TransAM account has been created for you", body: "<h1>New User Confirmation</h1><p>A new user account has been created for you in TransAM</p><p>Your username: {email}</p><p>Please go to {new_user_password_url} and follow the instructions to reset your password.</p>", message_enabled: false, is_system_template: true, active: true, is_implemented: true)

    MessageTemplate.create!(name: 'User2', delivery_rules: 'Sent on password reset',  subject:  "Reset password instructions", body: "<p>Hello {name}!</p><p>We have received a request to change your password. You can do this through the link below.</p><p>{link(Change my password)}</p><p>If you didn't request this, please ignore this email.</p><p>Your password won't change until you access the link above and create a new one.</p>", message_enabled: false, is_system_template: true, active: true, is_implemented: true)

    MessageTemplate.create!(name: 'User3', delivery_rules: 'Sent to locked user account',  subject:  'User account locked', body: "{locked_user.name} account was locked at {locked_user.locked_at}", active: true, is_implemented: true)



  end
end