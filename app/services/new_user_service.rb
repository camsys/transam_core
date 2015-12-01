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

    Rails.logger.debug "In Core NewUserService"
    user = User.new(params)
    Rails.logger.debug user.inspect
    user

  end

  # Override this method to invoke any business logic for post processing after
  # a user has been created and saved. For example, sending welcome emails,
  # configuring accounts, etc.
  def post_process(user)
    # No actions
  end

end
