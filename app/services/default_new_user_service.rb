class DefaultNewUserService
  def self.create_new_user(form_params)
    user = User.new(form_params)

    return user
  end

  def self.post_process(user)
    # No actions
  end
end