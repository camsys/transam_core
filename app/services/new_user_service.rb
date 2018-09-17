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
  def post_process(user)

    user.update_user_organization_filters

    user.viewable_organizations = user.user_organization_filter.try(:get_organizations) || []
    user.save!

    UserMailer.send_email_on_user_creation(user).deliver
  end
end
