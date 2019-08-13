json.message @message
json.session do
  json.(@user, :name, :email, :authentication_token, :failed_attempts) if @user
  if @user.organization
    json.organization @user.organization, :name
  end
end