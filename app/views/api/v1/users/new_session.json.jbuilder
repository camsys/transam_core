json.message @message
json.session do
  json.(@user, :email, :authentication_token, :failed_attempts) if @user
end