if @user
  json.user do 
    json.(@user, :id, :name, :first_name, :last_name, :email) 
    
    if @user.organization
      json.organization @user.organization, :id, :name, :short_name
    end
    json.privileges @user.privileges, :name, :label  end
end

