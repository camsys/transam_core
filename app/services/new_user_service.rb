#------------------------------------------------------------------------------
#
# NewUserService
#
# Contains business logic associated with creating new users
#
#------------------------------------------------------------------------------

class NewUserService

  def build(form_params)

    user = User.new(form_params)
    # Set up a default password for them
    user.password = SecureRandom.base64(8)
    # Activate the account immediately
    user.active = true
    # Override opt-in for email notifications
    user.notify_via_email = true

    return user
  end

  # Steps to take if the user was valid
  def post_process(user, assume_user_exists=false)

    user.update_user_organization_filters unless Rails.application.config.try(:user_organization_filters_ignored).present?

    user.viewable_organizations = user.user_organization_filters.system_filters.sorted.first.try(:get_organizations) || user.organizations
    user.save!

    unless assume_user_exists

      system_user = User.where(first_name: 'system', last_name: 'user').first
      message_template = MessageTemplate.find_by(name: 'User1')
      message_body =  MessageTemplateMessageGenerator.new.generate(message_template,[user.email, Rails.application.routes.url_helpers.new_user_password_url])


      msg               = Message.new
      msg.user          = system_user
      msg.organization  = system_user.organization
      msg.to_user       = user
      msg.subject       = message_template.subject
      msg.body          = message_body
      msg.priority_type = message_template.priority_type
      msg.message_template = message_template
      msg.active     = message_template.active
      msg.save

      UserMailer.send_email_on_user_creation(user).deliver
    end

  end
end
