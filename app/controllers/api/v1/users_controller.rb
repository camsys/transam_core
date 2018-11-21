class Api::V1::UsersController < Api::ApiController
  # Signs in an existing user, returning auth token
  # POST /sign_in
  # Leverages devise lockable module: https://github.com/plataformatec/devise/blob/master/lib/devise/models/lockable.rb
  def new_session
    @user = User.find_by(email: params[:email].downcase)
    @fail_status = :bad_request
    
    # Check if a user was found based on the passed email. If so, continue authentication.
    if @user.present?
      # checks if password is incorrect and user is locked, and unlocks if lock is expired
      if @user.valid_for_api_authentication?(params[:password])
        @user.ensure_authentication_token
      else
        # Otherwise, add some errors to the response depending on what went wrong.

        # Wokaround for useful but protected method
        if @user.on_last_attempt?
          @errors[:last_attempt] = "You have one more attempt before account is locked for #{User.unlock_in / 60} minutes."
        end

        if @user.access_locked?
          @errors[:locked] = "User account is temporarily locked. Try again in #{@user.time_until_unlock} minutes."
        end
        
        unless @user.access_locked? || @user.valid_password?(params[:password])
          @errors[:password] = "Incorrect password for #{@user.email}."
        end
        
        @fail_status = :unauthorized
        @errors = @errors.merge(@user.errors.to_h)            
      end
    else
      @errors[:email] = "Could not find user with email #{params[:email]}"
    end

    # Check if any errors were recorded. If not, send a success response.
    if @errors.empty?
      @message = "User Signed In Successfully"
    else # If there are any errors, send back a failure response.
      @status = :fail
      @data = {errors: @errors}
      render status: @fail_status
    end
  end

  # Signs out a user based on email and auth token headers
  # DELETE /sign_out
  def end_session
    
    if @user && @user.reset_authentication_token
      @message = "User #{@user.email} successfully signed out."
    else
      @status = :fail
      @data = {
        message: "Could not sign out user",
        auth_headers: auth_headers
      }
      render status: :bad_request
    end
  end

  # Given email, look up user profile
  # GET /profile
  def profile
    @user = User.find_by(email: params[:email].try(:downcase))
    unless @user
      @status = :fail
      @data = {email: "User #{params[:email]} not found."}
      render status: :not_found
    end
  end

  def list
    @organization = Organization.find_by_id(params[:organization_id])
    if @organization
      @users = @organization.users
    else
      @status = :fail
      @data = {organization: "Organization #{params[:organization_id]} not found."}
      render status: :not_found
    end
  end
end
