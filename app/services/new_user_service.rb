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
    # Set up a default password for thewm
    user.password = SecureRandom.base64(64)
    # Activate the account immediately
    user.active = true
    # Override opt-in for email notifications
    user.notify_via_email = true

    user.organizations << user.organization
    return user
  end

  # Steps to take if the user was valid
  def post_process(user)
    # Make sure the user has at least a user role
    unless user.has_role? :user
      user.add_role :user
    end

    UserMailer.send_email_on_user_creation(user).deliver
  end
end
