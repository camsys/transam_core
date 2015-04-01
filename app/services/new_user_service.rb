#------------------------------------------------------------------------------
#
# NewUserService
#
# Contains business logic associated with creating new users
#
#------------------------------------------------------------------------------
class NewUserService

  # Override this method to invoke business logic for creating new users.
  def build(params)

    user = User.new(params)
    user

  end

  # Override this method to invoke any business logic for post processing after
  # a user has been created and saved. For example, sending welcome emails,
  # configuring accounts, etc.
  def post_process(user)
    # No actions
  end

end
