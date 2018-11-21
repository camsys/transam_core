json.(@user, :id, :name, :email) if @user

json.organization @user.organization, :id, :name, :short_name

