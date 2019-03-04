if @user
  json.user do 
    json.(@user, :id, :name, :email) 
    
    if @user.organization
      json.organization @user.organization, :id, :name, :short_name
    end
  end
end

