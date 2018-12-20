module TransamTokenAuthentication
  
  def reset_authentication_token
    update_attributes(authentication_token: nil)
    ensure_authentication_token
    authentication_token.present?
  end
  
  # expose private last_attempt? method via this alias
  # returns true if this is the last chance to enter password before locking account
  def on_last_attempt?
    last_attempt?
  end
  
  # Returns number of minutes before account will be unlocked
  def time_until_unlock
    return 0 unless access_locked?
    return ((User.unlock_in - (Time.current - locked_at)) / 60).round
  end

  # Checks whether or not an API user is valid for authentication.
  def valid_for_api_authentication?(password=nil)
    # the valid_for_authentication? method is defined in Devise's models/authenticatable.rb and overloaded in models/lockable.rb
    # passed block will only run if user is NOT locked out
    valid_for_authentication? do
      # check if password is correct
      valid_password?(password) 
    end
  end
  
end
