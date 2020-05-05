class PasswordsController < Devise::PasswordsController

  # determine which layout to use based on the current user state
  layout :layout_by_resource

  # Determine which layout to use based on the authorized state
  def layout_by_resource
    if user_signed_in?
      "application"
    else
      "password"
    end
  end

  def create
    super do |resource|
      system_user = User.where(first_name: 'system', last_name: 'user').first
      message_template = MessageTemplate.find_by(name: 'User2')
      message_body =  MessageTemplateMessageGenerator.new.generate(message_template,[resource.name, "<a href='#'>Change my password</a>"]).html_safe

      msg               = Message.new
      msg.user          = system_user
      msg.organization  = system_user.organization
      msg.to_user       = resource
      msg.subject       = message_template.subject
      msg.body          = message_body
      msg.priority_type = message_template.priority_type
      msg.message_template = message_template
      msg.active     = message_template.active
      msg.save
    end
  end


end