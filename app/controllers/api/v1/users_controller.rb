class Api::V1::UsersController < Api::ApiController
  # Given email, look up user profile
  # GET /users/profile
  def profile
    @user = User.find_by(email: params[:email].try(:downcase))
    unless @user
      @status = :fail
      @data = {email: "User #{params[:email]} not found."}
      render status: :not_found
    end
  end

  # Given organization_id, look up users
  # GET /users
  def index
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
