if @user
  json.(@user, :id, :name, :email) 
  json.organization @user.organization, :id, :name, :short_name
end

