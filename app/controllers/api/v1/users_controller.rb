class Api::V1::UsersController < Api::ApiController
  def profile
    @user = User.find_by(email: params[:email])
  end
end
