class AddCoreMessageTemplateDescriptions < ActiveRecord::DataMigration
  def up
    message_templates = {
        'Task1' => 'A message is sent to a user with a Task with a due date less than one week in the future.',
        'Support1' => "A message is sent to Admin if an issue is submitted through the 'Report an Issue' feature on a weekly basis.",
        'Support2' => "A message is sent to Admin if the 'Delivery Rules' or 'Body' of a message is modified in any way.",
        'User1' => 'A message is sent to new users upon account creation, prompting users to establish a password.',
        'User2' => "A message is sent to existing users upon selecting 'Forgot My Password', prompting the user to reset their password.",
        'User3' => "A message is sent to any user with the 'Admin' privilege, when a user account has been locked, upon entering an incorrect password too many times."
    }

    message_templates.each do |name, description|
      MessageTemplate.find_by(name: name).update(description: description)
    end
  end

  def down
    message_templates = {
        'Task1' => 'A message is sent to a user with a Task with a due date less than one week in the future.',
        'Support1' => "A message is sent to Admin if an issue is submitted through the 'Report an Issue' feature on a weekly basis.",
        'Support2' => "A message is sent to Admin if the 'Delivery Rules' or 'Body' of a message is modified in any way.",
        'User1' => 'A message is sent to new users upon account creation, prompting users to establish a password.',
        'User2' => "A message is sent to existing users upon selecting 'Forgot My Password', prompting the user to reset their password.",
        'User3' => "A message is sent to any user with the 'Admin' privilege, when a user account has been locked, upon entering an incorrect password too many times."
    }

    message_templates.each do |name, description|
      MessageTemplate.find_by(name: name).update(description: nil)
    end
  end
end