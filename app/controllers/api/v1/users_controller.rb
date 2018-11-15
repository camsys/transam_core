class Api::V1::UsersController < Api::ApiController
  def profile
    @user = User.find_by(email: params[:email])
    unless @user
      @status = :fail
      @data = {email: "User #{params[:email]} not found."}
      render status: :not_found
    end
  end
end
