if @organization
  json.organization @organization, :id, :name, :short_name
end

if @users
  json.users @users, :id, :name, :email
end