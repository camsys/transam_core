class SetEmailEnabledFalseUser2MsgTemp < ActiveRecord::DataMigration
  def up
    # IF a system template is enabled, its email is also enabled but email_enabled may be false so messages dont send duplicates as other parts of the system already send the email (in this case devise)
    MessageTemplate.find_by(name: 'User2').update!(email_enabled: false)
  end
end